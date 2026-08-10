# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Leagues do
  describe '.by_sport_and_country' do
    subject(:leagues) { described_class.by_sport_and_country('soccer', 'England') }

    before do
      stub_request(:get, 'https://www.oddsportal.com/football/')
        .to_return(status: 200, body: read_fixture('pages/football.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/')
        .to_return(status: 200, body: read_fixture('pages/england.html'))
    end

    it 'resolves the country link and strips visible tournament counts' do
      expect(leagues).to contain_exactly('Premier League', 'Championship')
    end

    context 'when the country is not visible in the current catalog' do
      subject(:leagues) { described_class.by_sport_and_country('soccer', 'Invalid') }

      it { is_expected.to eq([]) }
    end
  end
end
