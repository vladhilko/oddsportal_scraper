# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Countries do
  describe '.by_sport' do
    subject { described_class.by_sport(sport_name) }

    context 'when choosen sport is `soccer`', vcr: 'oddsportal/countries/football' do
      let(:sport_name) { 'soccer' }

      it 'returns all countries available for this sport' do
        expect(subject).to contain_exactly(
          'Africa',
          'Algeria',
          'Argentina',
          'Armenia',
          'Asia',
          'Australia',
          'Austria',
          'Azerbaijan',
          'Belarus',
          'Belgium',
          'Bolivia',
          'Bosnia and Herzegovina',
          'Botswana',
          'Brazil',
          'Bulgaria',
          'Chile',
          'Colombia',
          'Costa Rica',
          'Croatia',
          'Cyprus',
          'Czech Republic',
          'Denmark',
          'Ecuador',
          'Egypt',
          'England',
          'Estonia',
          'Europe',
          'France',
          'Georgia',
          'Germany',
          'Ghana',
          'Greece',
          'Guatemala',
          'Honduras',
          'Hong Kong',
          'Hungary',
          'India',
          'Indonesia',
          'Iran',
          'Iraq',
          'Ireland',
          'Israel',
          'Italy',
          'Jamaica',
          'Japan',
          'Kazakhstan',
          'Kosovo',
          'Kuwait',
          'Lithuania',
          'Mauritania',
          'Mexico',
          'Montenegro',
          'Morocco',
          'Netherlands',
          'Nicaragua',
          'Nigeria',
          'North & Central America',
          'Northern Ireland',
          'Norway',
          'Panama',
          'Paraguay',
          'Peru',
          'Poland',
          'Portugal',
          'Qatar',
          'Romania',
          'Russia',
          'San Marino',
          'Saudi Arabia',
          'Scotland',
          'Serbia',
          'Slovakia',
          'Slovenia',
          'South Africa',
          'South America',
          'South Korea',
          'Spain',
          'Sweden',
          'Switzerland',
          'Tanzania',
          'Thailand',
          'Turkey',
          'USA',
          'Uganda',
          'Ukraine',
          'United Arab Emirates',
          'Uruguay',
          'Vietnam',
          'Wales',
          'World'
        )
      end
    end

    context 'when choosen sport is `basketball`', vcr: 'oddsportal/countries/basketball' do
      let(:sport_name) { 'basketball' }

      it 'returns all countries available for this sport' do
        expect(subject).to contain_exactly(
          'Africa',
          'Argentina',
          'Asia',
          'Australia',
          'Bahrain',
          'Brazil',
          'Bulgaria',
          'Chile',
          'China',
          'Croatia',
          'Czech Republic',
          'Denmark',
          'Europe',
          'Finland',
          'France',
          'Germany',
          'Greece',
          'Hungary',
          'Iceland',
          'Israel',
          'Italy',
          'Japan',
          'Lebanon',
          'Lithuania',
          'Mexico',
          'Philippines',
          'Poland',
          'Portugal',
          'Russia',
          'Slovakia',
          'Slovenia',
          'South Korea',
          'Spain',
          'Sweden',
          'Switzerland',
          'Taiwan',
          'Turkey',
          'United Kingdom',
          'Uruguay',
          'USA',
          'World'
        )
      end
    end

    context 'when choosen sport is `hockey`', vcr: 'oddsportal/countries/hockey' do
      let(:sport_name) { 'hockey' }

      it 'returns all countries available for this sport' do
        expect(subject).to contain_exactly(
          'Austria',
          'Belarus',
          'Canada',
          'Czech Republic',
          'Denmark',
          'Europe',
          'Finland',
          'France',
          'Germany',
          'Hungary',
          'Italy',
          'Latvia',
          'Norway',
          'Poland',
          'Russia',
          'Slovakia',
          'Sweden',
          'Switzerland',
          'USA',
          'Ukraine',
          'United Kingdom',
          'World'
        )
      end
    end

    context 'when choosen sport is invalid', vcr: 'oddsportal/countries/invalid' do
      let(:sport_name) { 'invalid' }

      it { is_expected.to be_empty }
    end
  end
end
