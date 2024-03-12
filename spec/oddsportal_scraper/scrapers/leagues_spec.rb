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
          'FA Cup',
          'Premier League 2',
          'Professional Development League',
          'Women’s Super League',
          'Women’s Championship',
          "Women's National League North",
          "Women's National League South"
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
          'Segunda RFEF - Group 3',
          'Segunda RFEF - Group 5',
          'Tercera RFEF - Group 2',
          'Tercera RFEF - Group 3',
          'Tercera RFEF - Group 6',
          'Tercera RFEF - Group 8',
          'Tercera RFEF - Group 15',
          'Tercera RFEF - Group 17',
          'Copa del Rey',
          'Liga F Women',
          'Copa de la Reina Women'
        )
      end
    end

    context 'when choosen sport is `hockey` and country is `Russia`', vcr: 'oddsportal/hockey/russia/leagues' do
      let(:sport_name) { 'hockey' }
      let(:country) { 'Russia' }

      it { is_expected.to contain_exactly('KHL', 'VHL', 'MHL', 'NMHL', 'WHL Women') }
    end

    context 'when choosen country is invalid', vcr: 'oddsportal/soccer/invalid/leagues' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'Invalid' }

      it { is_expected.to be_empty }
    end
  end
end
