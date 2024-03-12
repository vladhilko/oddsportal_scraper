# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Seasons < Base

      def self.by_sport_and_country_and_league(sport, country, league)
        new(sport:, country:, league:).by_sport_and_country_and_league
      end

      def initialize(sport:, country:, league:)
        @sport = sport
        @country = country.downcase
        @league = league.downcase.split(' ').join('-')
      end

      def by_sport_and_country_and_league
        raw_seasons_list_by(sport, country, league).fetch('seasons')
      rescue Mechanize::ResponseCodeError
        []
      end

      private

      attr_reader :sport, :country, :league

      def raw_seasons_list_by(sport, country, league)
        Wombat.crawl do
          base_url BASE_URL
          path "/#{sport}/#{country}/#{league}/results"

          seasons({ css: 'ul.main-filter li span strong a' }, :list) do |seasons|
            seasons.delete_if { ['NEXT MATCHES', 'OUTRIGHTS', 'RESULTS', 'STANDINGS'].include?(_1) }
          end
        end
      end

    end
  end
end
