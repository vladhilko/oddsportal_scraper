# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::SportNames do
  describe '.call' do
    subject { described_class.call }

    it 'returns all sport names available on the oddsportal', vcr: 'oddsportal/sport_names' do
      expect(subject).to contain_exactly(
        'Soccer',
        'Basketball',
        'Baseball',
        'Hockey',
        'Tennis',
        'American football',
        'Aussie rules',
        'Badminton',
        'Bandy',
        'Beach soccer',
        'Beach volleyball',
        'Boxing',
        'Cricket',
        'Darts',
        'eSports',
        'Floorball',
        'Futsal',
        'Handball',
        'MMA',
        'Rugby League',
        'Rugby Union',
        'Snooker',
        'Volleyball',
        'Water polo'
      )
    end
  end
end
