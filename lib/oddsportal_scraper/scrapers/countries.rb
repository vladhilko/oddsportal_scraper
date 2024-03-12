# frozen_string_literal: true

module OddsportalScraper
  module Scrapers
    class Countries < Base

      def self.by_sport(sport)
        new.by_sport(sport)
      end

      def by_sport(sport)
        raw_countries_list_by(sport).fetch('countries').uniq.sort
      rescue Mechanize::ResponseCodeError
        []
      end

      private

      def raw_countries_list_by(sport)
        Wombat.crawl do
          base_url BASE_URL
          path "/#{sport}"

          countries({ css: 'th a.bfl' }, :list) do |countries|
            countries.map { _1.gsub(160.chr('UTF-8'), '') }
                     .tap { _1.delete(sport.capitalize) }
          end
        end
      end

    end
  end
end
