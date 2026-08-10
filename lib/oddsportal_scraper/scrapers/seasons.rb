# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Seasons < Base
      def self.by_sport_and_country_and_league(sport, country, league)
        new(sport:, country:, league:).call
      end

      def initialize(sport:, country:, league:, http_client: HttpClient.new)
        super(http_client:)
        @sport = sport
        @country = country
        @league = league
      end

      def call
        country_document = country_page(sport)
        return [] unless country_document

        country_path = country_href(country_document, sport, country)
        return [] unless country_path

        country_document = fetch_document(country_path)
        return [] unless country_document

        league_path = league_href(country_document, sport, country, league)
        return [] unless league_path

        document = fetch_document(results_path(league_path))
        return [] unless document

        season_links(document).map { |link| link[:name] }
      end

      private

      attr_reader :sport, :country, :league
    end
  end
end
