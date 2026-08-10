# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Seasons do
  describe '.by_sport_and_country_and_league' do
    subject(:seasons) { described_class.by_sport_and_country_and_league('soccer', 'England', 'Premier League') }

    before do
      stub_request(:get, 'https://www.oddsportal.com/football/')
        .to_return(status: 200, body: read_fixture('pages/football.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/')
        .to_return(status: 200, body: read_fixture('pages/england.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league/results/')
        .to_return(status: 200, body: read_fixture('pages/premier_league_results.html'))
    end

    it 'reads season tabs from the current results page' do
      expect(seasons).to eq(['2020/2021', '2019/2020', '2018/2019'])
    end

    context 'when the league is not visible in the current catalog' do
      subject(:seasons) { described_class.by_sport_and_country_and_league('soccer', 'England', 'Invalid') }

      it { is_expected.to eq([]) }
    end
  end
end
