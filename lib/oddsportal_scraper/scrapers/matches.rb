# frozen_string_literal: true

require 'time'
require 'tzinfo'

module OddsportalScraper
  module Scrapers
    class Matches < Base
      MAX_ARCHIVE_PAGES = 200
      MAX_EMPTY_ARCHIVE_ATTEMPTS = 3
      ODDSPORTAL_TIMEZONE = TZInfo::Timezone.get('Europe/Berlin')

      def self.by_sport_and_country_and_league_and_season(sport, country, league, season)
        new(sport:, country:, league:, season:).call
      end

      def initialize(sport:, country:, league:, season:, http_client: HttpClient.new)
        super(http_client:)
        @sport = sport
        @country = country
        @league = league
        @season = season
      end

      def call
        fetch_http_matches
      rescue TransportError, ProtocolError
        browser_fallback_matches
      end

      private

      def fetch_http_matches
        season_path = resolve_season_href(sport:, country:, league:, season:)
        return [] unless season_path

        MAX_EMPTY_ARCHIVE_ATTEMPTS.times do |attempt|
          rows = fetch_season_archive_rows(season_path)
          return rows unless rows.empty? && attempt < MAX_EMPTY_ARCHIVE_ATTEMPTS - 1
        end

        []
      end

      def fetch_season_archive_rows(season_path)
        season_response = fetch_response(season_path)
        return [] unless season_response

        document = Nokogiri::HTML(season_response.body)
        archive_path = archive_path_from(season_response.body)
        return [] if archive_path.nil? && empty_result_page?(document)
        if archive_path.nil?
          raise ProtocolError,
                "OddsPortal season page did not expose an archive endpoint: #{season_path}"
        end

        fetch_archive_rows(archive_path).map { |row| normalize_row(row) }
      end

      def browser_fallback_matches
        raise unless BrowserFallback.enabled?

        BrowserFallback::Matches.call(sport:, country:, league:, season:)
      end

      attr_reader :sport, :country, :league, :season

      def archive_path_from(body)
        value = body.to_s.scan(/ajaxUrl\\?["']\s*:\s*\\?["']([^"\\]+)/).flatten.find do |candidate|
          candidate.include?('/ajax-sport-country-tournament-archive_')
        end
        value&.gsub('\\/', '/')
      end

      def empty_result_page?(document)
        document.at_css('[data-testid="null-result-message"]') ||
          document.text.match?(/no matches can be displayed because there are no odds available/i)
      end

      def fetch_archive_rows(archive_path)
        first_page = decode_archive(archive_path)
        data = archive_data(first_page)
        return [] if empty_archive_data?(data)

        rows = rows_for(data)
        page_count = page_count_for(data)

        unless page_count.between?(
          1, MAX_ARCHIVE_PAGES
        )
          raise ProtocolError,
                "OddsPortal archive page count is invalid: #{page_count.inspect}"
        end

        2.upto(page_count) do |page_number|
          page = decode_archive(page_url(archive_path, page_number))
          rows.concat(rows_for(archive_data(page)))
        end

        rows
      end

      def decode_archive(path)
        response = http_client.get(archive_url(path))
        ArchiveDecoder.decode(response.body)
      end

      def archive_data(payload)
        data = payload['d'] || payload['data']
        raise ProtocolError, 'OddsPortal archive payload did not contain data' unless data.is_a?(Hash)
        return data if empty_archive_data?(data) || data['rows'].is_a?(Array)

        raise ProtocolError, 'OddsPortal archive payload did not contain rows'
      end

      def rows_for(data)
        rows = data['rows']
        return rows if rows.is_a?(Array)

        return [] if empty_archive_data?(data)

        raise ProtocolError, 'OddsPortal archive payload did not contain rows'
      end

      def empty_archive_data?(data)
        data['nullResultText'].to_s.strip != '' || data['null-result-text'].to_s.strip != ''
      end

      def page_count_for(data)
        explicit_page_count = data.dig('pagination', 'pageCount') || data['pageCount']
        return explicit_page_count.to_i if explicit_page_count

        total = data['total'].to_i
        per_page = data['onePage'].to_i
        return 1 if total.zero? && data['rows'].empty?
        return 0 if per_page.zero?

        (total.to_f / per_page).ceil
      end

      def page_url(path, page_number)
        uri = URI.parse(archive_url(path))
        uri.path = "#{uri.path.sub(%r{/+\z}, '')}/page/#{page_number}/"
        uri.to_s.sub(/\A#{Regexp.escape(ARCHIVE_BASE_URL)}/, '')
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def normalize_row(row)
        home = row['home-name'] || row['homeName']
        away = row['away-name'] || row['awayName']
        timestamp = row['date-start-timestamp'] || row['dateStartTimestamp']
        if home.to_s.empty? || away.to_s.empty? || timestamp.nil?
          raise ProtocolError,
                'OddsPortal archive row is missing participants or timestamp'
        end

        time = ODDSPORTAL_TIMEZONE.to_local(Time.at(timestamp.to_i))
        odds = row['odds'].is_a?(Array) ? row['odds'].first(3).map { |odd| format_odd(odd) } : []

        {
          match_date: time.strftime('%d %b %Y'),
          match_time: time.strftime('%H:%M'),
          participants: "#{home} - #{away}",
          score: score_for(row),
          odds: {
            home_win: odds[0],
            draw: odds[1],
            away_win: odds[2]
          }
        }
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def format_odd(odd)
        value = odd.is_a?(Hash) ? (odd['avgOdds'] || odd['avg-odds'] || odd['value']) : odd
        return nil if value.nil? || value.to_s.strip.empty?

        format('%.2f', Float(value))
      rescue ArgumentError, TypeError
        nil
      end

      def score_for(row)
        stage = row['event-stage-name'].to_s
        return 'canc.' if stage.match?(/cancel|postpon|abandon/i)

        result = row['result'] || row['postmatchResult']
        if result.to_s.empty? && row['homeResult'] && row['awayResult']
          result = "#{row['homeResult']}:#{row['awayResult']}"
        end
        result.to_s.gsub(/[\u00a0\u202f]/, ' ').strip
      end
    end
  end
end
