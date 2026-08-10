# frozen_string_literal: true

require 'cgi'
require 'nokogiri'
require 'uri'

module OddsportalScraper
  module Scrapers
    class Base
      BASE_URL = 'https://www.oddsportal.com'
      ARCHIVE_BASE_URL = 'https://backend.oddsportal.com'

      def self.call
        new.call
      end

      def initialize(http_client: HttpClient.new)
        @http_client = http_client
      end

      protected

      attr_reader :http_client

      def fetch_response(path_or_url)
        http_client.get(url_for(path_or_url))
      rescue TransportError => e
        return nil if e.not_found?

        raise
      end

      def fetch_document(path_or_url)
        response = fetch_response(path_or_url)
        response && Nokogiri::HTML(response.body)
      end

      def fetch_body(path_or_url)
        response = fetch_response(path_or_url)
        response&.body
      end

      def sport_segment(sport)
        segment = sport.to_s.strip.downcase
        return 'football' if segment == 'soccer'

        segment.gsub(/[^a-z0-9-]+/, '-')
      end

      def url_for(path_or_url, base_url: BASE_URL)
        value = path_or_url.to_s
        return value if value.match?(%r{\Ahttps?://})

        URI.join("#{base_url}/", value.sub(%r{\A/}, '')).to_s
      end

      def archive_url(path_or_url)
        url_for(path_or_url, base_url: ARCHIVE_BASE_URL)
      end

      def country_page(sport)
        fetch_document("/#{sport_segment(sport)}/")
      end

      def country_href(document, sport, country)
        target = normalize_name(country)

        link = country_links(document, sport).find do |candidate|
          link_name = normalize_name(link_text(candidate))
          link_slug = route_segments(candidate['href']).last
          link_name == target || slugify(link_name) == slugify(target) || link_slug == slugify(target)
        end
        return link['href'] if link

        country_slug = country_route_slugs(document, sport).find { |slug| slug == slugify(target) }
        country_slug && "/#{sport_segment(sport)}/#{country_slug}/"
      end

      def country_route_slugs(document, sport)
        segment = sport_segment(sport)
        document.css('a[href]').filter_map do |link|
          parts = route_segments(link['href'])
          next unless parts.first == segment && parts.length >= 3
          next if %w[today tomorrow yesterday].include?(parts[1])

          parts[1]
        end.uniq
      end

      def country_name_from_slug(slug)
        return 'USA' if slug == 'usa'

        slug.split('-').map(&:capitalize).join(' ')
      end

      def league_href(document, sport, country, league)
        target = normalize_name(league)
        tournament_links(document, sport, country).find do |link|
          link_name = normalize_name(strip_count(link_text(link)))
          link_name == target || slugify(link_name) == slugify(target)
        end&.[]('href')
      end

      def season_href(document, season)
        target = canonical_season(season)
        season_links(document).find { |link| link[:name] == target }&.fetch(:href)
      end

      def country_links(document, sport)
        segment = sport_segment(sport)
        document.css('a[href]').select do |link|
          route_segments(link['href']).then { |parts| parts.length == 2 && parts.first == segment }
        end
      end

      # The fallback parser must support both semantic links and older route-only pages.
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def tournament_links(document, sport, country)
        semantic_links = semantic_tournament_links(document)
        links = semantic_links.empty? ? document.css('a[href]') : semantic_links
        segment = sport_segment(sport)
        country_slug = slugify(country)

        links = links.select do |link|
          parts = route_segments(link['href'])
          parts.first == segment && parts[1] == country_slug && parts.length >= 3 &&
            (semantic_links.any? || parts.include?('results') || link['href'].to_s.include?('/results'))
        end
        links.uniq { |link| link['href'] }
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def semantic_tournament_links(document)
        document.css(
          '[data-testid="country-page-tournament-box"] a[href], ' \
          'a[data-testid="country-page-tournament-name"]'
        ).select { |link| route_segments(link['href']).length >= 3 }
      end

      def season_links(document)
        links = document.css('a[href]').filter_map do |link|
          href = link['href'].to_s
          text = normalize_name(link_text(link))
          season = text[%r{\A\d{4}\s*[-/]\s*\d{4}\z}]
          season_match = href.match(%r{-(\d{4})-(\d{4})(?:/results)?/?(?:\?|#|\z)})
          season ||= "#{season_match[1]}/#{season_match[2]}" if season_match
          next if season.to_s.empty?

          { name: canonical_season(season), href: }
        end
        links.uniq { |link| link[:name] }
      end

      def resolve_season_href(sport:, country:, league:, season:)
        country_document = country_page(sport)
        return nil unless country_document

        country_path = country_href(country_document, sport, country)
        return nil unless country_path

        country_document = fetch_document(country_path)
        return nil unless country_document

        league_path = league_href(country_document, sport, country, league)
        return nil unless league_path

        league_document = fetch_document(results_path(league_path))
        return nil unless league_document

        season_href(league_document, season)
      end

      def results_path(path)
        value = path.to_s.sub(%r{/+\z}, '')
        value.end_with?('/results') ? "#{value}/" : "#{value}/results/"
      end

      def route_segments(href)
        path = URI.parse(CGI.unescapeHTML(href.to_s)).path
        path.split('/').reject(&:empty?)
      rescue URI::InvalidURIError
        []
      end

      def link_text(link)
        link.at_css('[data-testid="country-page-tournament-name"]')&.text || link.text
      end

      def strip_count(value)
        normalize_name(value).sub(/\s*\(\s*\d+\s*\)\s*\z/, '')
      end

      def normalize_name(value)
        CGI.unescapeHTML(value.to_s).gsub(/[\u00a0\u202f]/, ' ').gsub(/\s+/, ' ').strip
      end

      def slugify(value)
        normalize_name(value).downcase.gsub(/[’']/, '').gsub(/[^a-z0-9]+/, '-').sub(/\A-|-\z/, '')
      end

      def canonical_season(value)
        start_year, end_year = value.to_s.split(%r{[-/]})
        return normalize_name(value) unless start_year.to_s.match?(/\A\d{4}\z/) && end_year.to_s.match?(/\A\d{4}\z/)

        "#{start_year}/#{end_year}"
      end
    end
  end
end
