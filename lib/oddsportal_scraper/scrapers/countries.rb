# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Countries < Base
      def self.by_sport(sport)
        new(sport:).call
      end

      def initialize(sport:, http_client: HttpClient.new)
        super(http_client:)
        @sport = sport
      end

      def call
        document = country_page(sport)
        return [] unless document

        countries = country_names(document)

        if countries.empty?
          raise ProtocolError,
                "OddsPortal country page for #{sport.inspect} contained no country links"
        end

        countries.uniq.sort
      end

      private

      attr_reader :sport

      def country_names(document)
        countries = country_links(document, sport).filter_map do |link|
          name = normalize_name(link_text(link))
          name unless name.empty? || utility_country?(link)
        end
        countries = country_route_slugs(document, sport).map { |slug| country_name_from_slug(slug) } if countries.empty?
        countries
      end

      def utility_country?(link)
        %w[today tomorrow yesterday].include?(route_segments(link['href']).last)
      end
    end
  end
end
