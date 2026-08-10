# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OddsPortal live route smoke', :live do
  before do
    unless ENV['ODDSPORTAL_SCRAPER_LIVE_SPECS'] == '1'
      skip 'set ODDSPORTAL_SCRAPER_LIVE_SPECS=1 to run live smoke checks'
    end
  end

  [
    %w[soccer England],
    %w[basketball USA],
    %w[hockey USA]
  ].each do |sport, country|
    it "resolves the current #{sport} route" do
      expect(OddsportalScraper.countries(sport:)).to include(country)
      expect(OddsportalScraper.leagues(sport:, country:)).not_to be_empty
    end
  end
end
