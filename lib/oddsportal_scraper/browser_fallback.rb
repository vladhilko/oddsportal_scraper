# frozen_string_literal: true

module OddsportalScraper
  module BrowserFallback
    def self.enabled?
      ENV['ODDSPORTAL_SCRAPER_BROWSER_FALLBACK'] == '1'
    end

    class Matches
      def self.call(sport:, country:, league:, season:)
        new(sport:, country:, league:, season:).call
      end

      def initialize(sport:, country:, league:, season:)
        @sport = sport
        @country = country
        @league = league
        @season = season
      end

      def call
        require 'selenium-webdriver'

        driver = Selenium::WebDriver.for(:chrome, options: chrome_options)
        driver.navigate.to(url)
        wait_for_rows(driver)
        parse_rows(driver.page_source)
      rescue LoadError => e
        raise BrowserUnavailableError, "Browser fallback requires selenium-webdriver: #{e.message}"
      rescue Selenium::WebDriver::Error => e
        raise BrowserUnavailableError, "Browser fallback could not start Chrome: #{e.message}"
      ensure
        driver&.quit
      end

      private

      attr_reader :sport, :country, :league, :season

      def url
        sport_path = sport.to_s.downcase == 'soccer' ? 'football' : sport.to_s.downcase
        country_path = country.to_s.downcase.strip.gsub(/[^a-z0-9]+/, '-')
        league_path = league.to_s.downcase.strip.gsub(/[^a-z0-9]+/, '-')
        season_start, season_end = season.to_s.split(%r{[-/]})
        season_path = "#{league_path}-#{season_start}-#{season_end}"
        "https://www.oddsportal.com/#{sport_path}/#{country_path}/#{season_path}/results/"
      end

      def chrome_options
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless=new')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-background-networking')
        options.add_argument('--disable-extensions')
        options.add_argument('--no-first-run')
        options.add_argument('--no-default-browser-check')
        options.add_argument('--window-size=1440,2200')
        options.binary = ENV['ODDSPORTAL_CHROME_BINARY'] if ENV['ODDSPORTAL_CHROME_BINARY']
        options
      end

      def wait_for_rows(driver)
        Selenium::WebDriver::Wait.new(timeout: 15).until do
          driver.find_elements(css: '[data-testid="game-row"]').any? ||
            driver.find_elements(css: '[data-testid="null-result-message"]').any?
        end
      end

      def parse_rows(html)
        document = Nokogiri::HTML(html)
        document.css('[data-testid="game-row"]').map do |row|
          participants = row.css('[data-testid="participant-name"]').map { |node| normalize(node.text) }
          odds = row.css('[data-testid^="odd-container-"]').map { |node| normalize(node.text) }
          {
            match_date: normalize(row.at_css('[data-testid="date-header"]')&.text),
            match_time: normalize(row.at_css('[data-testid="time-item"]')&.text),
            participants: participants.join(' - '),
            score: normalize(row.text[/\b\d+\s*[:-]\s*\d+\b/]),
            odds: {
              home_win: odds[0],
              draw: odds[1],
              away_win: odds[2]
            }
          }
        end
      end

      def normalize(value)
        value.to_s.gsub(/[\u00a0\u202f]/, ' ').gsub(/\s+/, ' ').strip
      end
    end
  end
end
