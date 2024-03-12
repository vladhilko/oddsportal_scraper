# frozen_string_literal: true

require_relative 'oddsportal_scraper/version'
require_relative 'oddsportal_scraper/scrapers/base'
require_relative 'oddsportal_scraper/scrapers/sport_names'
require_relative 'oddsportal_scraper/scrapers/countries'
require_relative 'oddsportal_scraper/scrapers/leagues'
require_relative 'oddsportal_scraper/scrapers/seasons'
require_relative 'oddsportal_scraper/scrapers/matches'

module OddsportalScraper
  ROOT_DIR = File.expand_path('..', __dir__)

  class Error < StandardError; end

  class << self

    def sport_names
      Scrapers::SportNames.call
    end

    def countries(sport: sport_name)
      Scrapers::Countries.by_sport(sport)
    end

    def leagues(sport:, country:)
      Scrapers::Leagues.by_sport_and_country(sport, country)
    end

    def seasons(sport:, country:, league:)
      Scrapers::Seasons.by_sport_and_country_and_league(sport, country, league)
    end

    def matches(sport:, country:, league:, season:)
      Scrapers::Matches.by_sport_and_country_and_league_and_season(sport, country, league, season)
    end

  end
end
