# frozen_string_literal: true

require 'kimurai'
require 'pry'

module OddsportalScraper
  module Scrapers
    class Matches < Kimurai::Base

      @name = 'match_scraper'
      @engine = :selenium_chrome

      def self.by_sport_and_country_and_league_and_season(sport, country, league, season)
        @sport = sport
        @country = country.downcase
        @league = league.downcase.split(' ').join('-')
        season_starts, season_ends = season.split(/[-\/]/)
        @season = "#{season_starts}-#{season_ends}"

        @path = "#{@sport}/#{@country}/#{@league}-#{@season}/results/"
        url = "https://www.oddsportal.com/#{@path}"

        parse!(:parse, url:, data: { season_starts: season_starts, season_ends: season_ends })
      end

      def parse(response, url:, data:, **)
        browser.visit("#{url}#/page/#{1}/")
        parse_page(season_starts: data[:season_starts], season_ends: data[:season_ends])


        # return [] if page_does_not_exist?(response) || no_odds_available_for_the_season?(response)

        # last_page_num = response.css('div#pagination a').last.attributes.fetch('href').value.split('/').last.to_i
        # all_season_matches = []

        # (1..last_page_num).each do |page_number|
        #   browser.visit("#{url}#/page/#{page_number}/")
        #   all_season_matches.concat(parse_page_with_matches)
        # end
        # all_season_matches
      end

      private

      def page_does_not_exist?(response)
        response.css('#col-content h1').text == 'Page not found' &&
          response.css('#col-content p').text == 'This page not exist on OddsPortal.com!'
      end

      def no_odds_available_for_the_season?(response)
        response.css('div.message-info ul li div.cms').last.text.include?(
          'Unfortunately, '\
          'no matches can be displayed because there are no odds available from your selected bookmakers.'
        )
      end

      def parse_page(season_starts:, season_ends:)
        scroll_till_the_end

        elements_with_dash = browser.find_all(:xpath, "//a[contains(text(), '–')]")
        matches = []
        elements_with_dash.each do |element|
          parent_with_class = element.find(:xpath, './ancestor::div[contains(@class, "group") and contains(@class, "flex")]')
          date = parent_with_class.find_all(:xpath, "./ancestor::*/preceding::*[contains(text(), #{season_starts}) or contains(text(), #{season_ends})][1]").map(&:text).last
          match_row = parent_with_class.find_all('.//*[not(*) and normalize-space()]')

          matches << match_row_hash(match_row.map(&:text), date: date)
        end
        matches
      end

      def scroll_till_the_end
        browser.execute_script("window.scrollBy(0,10000)")
        sleep 1
        browser.execute_script("window.scrollBy(0,10000)")
        sleep 1
      end

      def match_row_hash(match_row, date:)
        {
          match_date: date,
          match_time: match_row[0],
          participants: "#{match_row[1]} - #{match_row[6]}",
          score: "#{match_row[3]}:#{match_row[5]}",
          odds: {
            home_win: match_row[9],
            draw: match_row[10],
            away_win: match_row[11]
          }
        }
      end

    end
  end
end
