# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Leagues < Base
      def self.by_sport_and_country(sport, country)
        new(sport:, country:).call
      end

      def initialize(sport:, country:, http_client: HttpClient.new)
        super(http_client:)
        @sport = sport
        @country = country
      end

      def call
        document = country_page(sport)
        return [] unless document

        country_path = country_href(document, sport, country)
        return [] unless country_path

        document = fetch_document(country_path)
        return [] unless document

        tournament_links(document, sport, country).filter_map do |link|
          name = strip_count(link_text(link))
          name unless name.empty?
        end.uniq
      end

      private

      attr_reader :sport, :country
    end
  end
end
