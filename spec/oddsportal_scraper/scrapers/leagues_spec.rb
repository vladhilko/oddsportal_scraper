# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Leagues do
  describe '.by_sport_and_country' do
    subject { described_class.by_sport_and_country(sport_name, country) }

    context 'when choosen sport is `soccer` and country is `England`', vcr: 'oddsportal/soccer/england/leagues' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }

      it 'returns all leagues available for this sport and country' do
        expect(subject).to contain_exactly(
          'Premier League',
          'Championship',
          'League One',
          'League Two',
          'National League',
          'National League North',
          'National League South',
          'NPL Premier Division',
          'Southern League Central Division',
          'Southern League South Division',
          'Isthmian League Premier Division',
          'EFL Trophy',
          'FA Trophy',
          'Premier League 2',
          'Professional Development League',
          'Women’s Super League'
        )
      end
    end

    context 'when choosen sport is `soccer` and country is `Spain`', vcr: 'oddsportal/soccer/spain/leagues' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'Spain' }

      it 'returns all leagues available for this sport and country' do
        expect(subject).to contain_exactly(
          'LaLiga',
          'LaLiga2',
          'Primera RFEF - Group 1',
          'Primera RFEF - Group 2',
          'Segunda RFEF - Group 1',
          'Segunda RFEF - Group 2',
          'Segunda RFEF - Group 3',
          'Segunda RFEF - Group 4',
          'Segunda RFEF - Group 5',
          'Tercera RFEF - Group 1',
          'Tercera RFEF - Group 2',
          'Tercera RFEF - Group 3',
          'Tercera RFEF - Group 4',
          'Tercera RFEF - Group 5',
          'Tercera RFEF - Group 6',
          'Tercera RFEF - Group 7',
          'Tercera RFEF - Group 8',
          'Tercera RFEF - Group 9',
          'Tercera RFEF - Group 10',
          'Tercera RFEF - Group 11',
          'Tercera RFEF - Group 12',
          'Tercera RFEF - Group 14',
          'Tercera RFEF - Group 15',
          'Tercera RFEF - Group 16',
          'Tercera RFEF - Group 17',
          'Tercera RFEF - Group 18',
          'Liga F Women',
          'Primera Federacion Women'
        )
      end
    end

    context 'when choosen sport is `hockey` and country is `Russia`', vcr: 'oddsportal/hockey/russia/leagues' do
      let(:sport_name) { 'hockey' }
      let(:country) { 'Russia' }

      it { is_expected.to contain_exactly('KHL', 'VHL', 'MHL', 'NMHL') }
    end

    context 'when choosen country is invalid', vcr: 'oddsportal/soccer/invalid/leagues' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'Invalid' }

      it { is_expected.to be_empty }
    end
  end
end
