# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class SportNames < Base

      def call
        parse.fetch('sport_names')
      end

      private

      def parse
        Wombat.crawl do
          base_url BASE_URL
          path '/'

          sport_names({ css: '.sport_name a' }, :list)
        end
      end

    end
  end
end
