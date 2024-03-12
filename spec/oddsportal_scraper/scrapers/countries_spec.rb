# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Countries do
  describe '.by_sport' do
    subject { described_class.by_sport(sport_name) }

    context 'when choosen sport is `soccer`', vcr: 'oddsportal/countries/soccer' do
      let(:sport_name) { 'soccer' }

      it 'returns all countries available for this sport' do
        expect(subject).to contain_exactly(
          'Angola',
          'Argentina',
          'Australia',
          'Austria',
          'Azerbaijan',
          'Belgium',
          'Bosnia and Herzegovina',
          'Brazil',
          'Bulgaria',
          'Burkina Faso',
          'Canada',
          'Chile',
          'China',
          'Colombia',
          'Costa Rica',
          'Croatia',
          'Cyprus',
          'Czech Republic',
          'Denmark',
          'Ecuador',
          'Egypt',
          'El Salvador',
          'England',
          'Estonia',
          'Ethiopia',
          'Europe',
          'Finland',
          'France',
          'Germany',
          'Ghana',
          'Gibraltar',
          'Greece',
          'Guatemala',
          'Honduras',
          'Hungary',
          'Iceland',
          'India',
          'Indonesia',
          'Iran',
          'Ireland',
          'Israel',
          'Italy',
          'Ivory Coast',
          'Japan',
          'Jordan',
          'Kazakhstan',
          'Kuwait',
          'Kyrgyzstan',
          'Latvia',
          'Lebanon',
          'Liberia',
          'Lithuania',
          'Luxembourg',
          'Malaysia',
          'Malta',
          'Mauritania',
          'Mexico',
          'Moldova',
          'Morocco',
          'Myanmar',
          'Netherlands',
          'New Zealand',
          'Nicaragua',
          'North & Central America',
          'Northern Ireland',
          'Norway',
          'Oman',
          'Palestine',
          'Panama',
          'Paraguay',
          'Peru',
          'Poland',
          'Portugal',
          'Romania',
          'Russia',
          'Rwanda',
          'Scotland',
          'Senegal',
          'Serbia',
          'Singapore',
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
          'Venezuela',
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
          'Argentina',
          'Australia',
          'Austria',
          'Belgium',
          'Brazil',
          'Bulgaria',
          'Chile',
          'China',
          'Colombia',
          'Croatia',
          'Cyprus',
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
          'Lithuania',
          'Mexico',
          'Norway',
          'Paraguay',
          'Philippines',
          'Poland',
          'Portugal',
          'Romania',
          'Russia',
          'Serbia',
          'Slovakia',
          'Slovenia',
          'South Korea',
          'Spain',
          'Sweden',
          'Switzerland',
          'Turkey',
          'USA',
          'Ukraine',
          'United Kingdom',
          'Uruguay',
          'Venezuela',
          'World'
        )
      end
    end

    context 'when choosen sport is `hockey`', vcr: 'oddsportal/countries/hockey' do
      let(:sport_name) { 'hockey' }

      it 'returns all countries available for this sport' do
        expect(subject).to contain_exactly(
          'Asia',
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
          'Kazakhstan',
          'Latvia',
          'Norway',
          'Poland',
          'Russia',
          'Slovakia',
          'Sweden',
          'Switzerland',
          'USA',
          'United Kingdom'
        )
      end
    end

    context 'when choosen sport is invalid', vcr: 'oddsportal/countries/invalid' do
      let(:sport_name) { 'invalid' }

      it { is_expected.to be_empty }
    end
  end
end
