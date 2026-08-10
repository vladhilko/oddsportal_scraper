# frozen_string_literal: true

require 'kimurai'

module OddsportalScraper
  module Scrapers
    class Matches < Kimurai::Base
      @name = 'match_scraper'
      @engine = :selenium_chrome
      @config = { retry_request_errors: [Net::OpenTimeout, Net::ReadTimeout] }

      def self.by_sport_and_country_and_league_and_season(sport, country, league, season)
        @sport = sport
        @country = country.downcase
        @league = league.downcase.split.join('-')
        season_starts, season_ends = season.split(%r{[-/]})
        @season = "#{season_starts}-#{season_ends}"

        @path = "#{@sport}/#{@country}/#{@league}-#{@season}/results/"
        url = "https://www.oddsportal.com/#{@path}"

        spider = new
        spider.request_to(:parse, url:, data: { season_starts: season_starts, season_ends: season_ends })
      ensure
        spider.browser.destroy_driver! if spider&.instance_variable_get('@browser')
      end

      def parse(response, url:, data:, **)
        browser.visit("#{url}#/page/1/")
        last_page_num = response.css('div.pagination a.pagination-link').map(&:text).grep(/[0-9]+/).last.to_i

        all_season_matches = parse_page(season_starts: data[:season_starts], season_ends: data[:season_ends])

        if last_page_num > 1
          (2..last_page_num).each do |page_number|
            browser.visit("#{url}#/page/#{page_number}/")
            all_season_matches.concat(parse_page(season_starts: data[:season_starts], season_ends: data[:season_ends]))
          end
        end

        all_season_matches
      end

      private

      def parse_page(season_starts:, season_ends:)
        scroll_till_the_end

        match_result_with_dash = browser.find_all(:xpath, "//a[contains(text(), '–')]")
        match_result_with_dash.map do |element|
          match_result_element = element.find(:xpath,
                                              './ancestor::div[contains(@class, "group") and contains(@class, "flex")]')
          date_xpath = format(
            './ancestor::*/preceding::*[contains(text(), %<season_start>s) or contains(text(), %<season_end>s)][1]',
            season_start: season_starts,
            season_end: season_ends
          )
          date = match_result_element.find_all(:xpath, date_xpath).map(&:text).last
          match_row = match_result_element.find_all(:xpath, './/*[not(*) and normalize-space()]')

          match_row_hash(match_row.map(&:text), date: date)
        end
      end

      def scroll_till_the_end
        browser.execute_script('window.scrollBy(0,10000)')
        sleep 1
        browser.execute_script('window.scrollBy(0,10000)')
        sleep 1
        browser.execute_script('window.scrollBy(0,10000)')
        sleep 0.5
      end

      def match_row_hash(match_row, date:)
        {
          match_date: date,
          match_time: match_row[0],
          participants: "#{match_row[1]} - #{match_row[6]}",
          score: "#{match_row[3]}:#{match_row[5]}",
          odds: {
            home_win: match_row[8],
            draw: match_row[9],
            away_win: match_row[10]
          }
        }
      end
    end
  end
end
