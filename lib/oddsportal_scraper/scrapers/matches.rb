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
        @season = season.split('/').join('-')

        @path = "#{@sport}/#{@country}/#{@league}-#{@season}/results/"
        url = "https://www.oddsportal.com/#{@path}"

        parse!(:parse, url:)
      end

      def parse(response, url:, **)
        return [] if page_does_not_exist?(response) || no_odds_available_for_the_season?(response)

        last_page_num = response.css('div#pagination a').last.attributes.fetch('href').value.split('/').last.to_i
        all_season_matches = []

        (1..last_page_num).each do |page_number|
          browser.visit("#{url}#/page/#{page_number}/")
          all_season_matches.concat(parse_page_with_matches)
        end
        all_season_matches
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

      def parse_page_with_matches # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        tournament_table = browser.current_response.css('div#tournamentTable')

        matches = []
        match_date = nil
        tournament_table.css('tr').each do |match_day|
          if match_day.css('span.datet').text.present?
            match_date = match_day.css('span.datet').text
          elsif match_day.css('td.table-time').text.present?
            match_time = match_day.css('td.table-time').text
            participants = match_day.css('td.table-participant a').text
            score = match_day.css('td.table-score').text
            home_win, draw, away_win = match_day.css('td.odds-nowrp a').children.map(&:to_s)

            matches << {
              match_date:,
              match_time:,
              participants:,
              score:,
              odds: { home_win:, draw:, away_win: }
            }
          end
        end
        matches
      end

    end
  end
end
