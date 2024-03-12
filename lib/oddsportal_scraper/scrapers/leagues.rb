# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Leagues < Base

      def self.by_sport_and_country(sport, country)
        new(sport:, country:).by_sport_and_country
      end

      def initialize(sport:, country:)
        @sport = sport
        @country = country.downcase
      end

      def by_sport_and_country
        raw_leagues_list_by(sport, country).fetch('leagues')
      rescue Mechanize::ResponseCodeError
        []
      end

      private

      attr_reader :sport, :country

      def raw_leagues_list_by(sport, country)
        Wombat.crawl do
          base_url BASE_URL
          path "/#{sport}/#{country}"

          leagues({ css: "td a[foo='f']" }, :list)
        end
      end

    end
  end
end
