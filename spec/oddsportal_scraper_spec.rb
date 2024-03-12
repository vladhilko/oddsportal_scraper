# frozen_string_literal: true

RSpec.describe OddsportalScraper do
  it 'has a version number' do
    expect(OddsportalScraper::VERSION).not_to be_nil
  end

  describe '.sport_names' do
    subject { described_class.sport_names }

    before { allow(OddsportalScraper::Scrapers::SportNames).to receive(:call) }

    it 'calls correct scraper method' do
      subject

      expect(OddsportalScraper::Scrapers::SportNames).to have_received(:call)
    end
  end

  describe '.countries' do
    subject { described_class.countries(sport:) }

    let(:sport) { 'soccer' }

    before { allow(OddsportalScraper::Scrapers::Countries).to receive(:by_sport) }

    it 'calls correct scraper method' do
      subject

      expect(OddsportalScraper::Scrapers::Countries).to have_received(:by_sport).with(sport)
    end
  end

  describe '.leagues' do
    subject { described_class.leagues(sport:, country:) }

    let(:sport) { 'soccer' }
    let(:country) { 'England' }

    before { allow(OddsportalScraper::Scrapers::Leagues).to receive(:by_sport_and_country) }

    it 'calls correct scraper method' do
      subject

      expect(OddsportalScraper::Scrapers::Leagues).to have_received(:by_sport_and_country).with(sport, country)
    end
  end

  describe '.seasons' do
    subject { described_class.seasons(sport:, country:, league:) }

    let(:sport) { 'soccer' }
    let(:country) { 'England' }
    let(:league) { 'Premier League' }

    before { allow(OddsportalScraper::Scrapers::Seasons).to receive(:by_sport_and_country_and_league) }

    it 'calls correct scraper method' do
      subject

      expect(OddsportalScraper::Scrapers::Seasons).to have_received(:by_sport_and_country_and_league)
        .with(sport, country, league)
    end
  end

  describe '.matches' do
    subject { described_class.matches(sport:, country:, league:, season:) }

    let(:sport) { 'soccer' }
    let(:country) { 'England' }
    let(:league) { 'Premier League' }
    let(:season) { '2008-2009' }

    before { allow(OddsportalScraper::Scrapers::Matches).to receive(:by_sport_and_country_and_league_and_season) }

    it 'calls correct scraper method' do
      subject

      expect(OddsportalScraper::Scrapers::Matches).to have_received(:by_sport_and_country_and_league_and_season)
        .with(sport, country, league, season)
    end
  end
end
