# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Matches do
  describe '.by_sport_and_country_and_league_and_season', with_chromedriver: true do
    subject { described_class.by_sport_and_country_and_league_and_season(sport_name, country, league, season) }

    shared_examples 'a live matches response' do
      it 'returns the current public match response contract' do
        actual_response = subject

        expect(actual_response).to be_an(Array)
        actual_response.each do |actual_match|
          expect(actual_match).to include(:match_date, :match_time, :participants, :score, :odds)
          expect(actual_match[:participants]).to be_a(String)
          expect(actual_match[:odds]).to include(:home_win, :draw, :away_win)
        end
      end
    end

    context 'when choosen sport: `soccer`, country: `England`, league: `Premier League` and season: `2007-2008`' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Premier League' }
      let(:season) { '2007-2008' }

      include_examples 'a live matches response'
    end

    context 'when choosen sport: `soccer`, country: `England`, league: `Premier League` and season: `2019-2020`' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Premier League' }
      let(:season) { '2019-2020' }

      include_examples 'a live matches response'
    end

    context 'when choosen sport: `soccer`, country: `England`, league: `Championship` and season: `2019/2020`' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Championship' }
      let(:season) { '2019/2020' }

      include_examples 'a live matches response'
    end

    context 'when the given league does not exist' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'Switzerland' }
      let(:league) { 'Promotion League' }
      let(:season) { '2012/2013' }

      it { is_expected.to eq([]) }
    end

    context 'when there is no odds available for the given season' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Premier League' }
      let(:season) { '1998/1999' }

      it { is_expected.to eq([]) }
    end
  end
end
