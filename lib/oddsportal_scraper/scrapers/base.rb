# frozen_string_literal: true

require 'wombat'

module OddsportalScraper
  module Scrapers
    class Base
      BASE_URL = 'https://oddsportal.com'

      def self.call
        new.call
      end
    end
  end
end
