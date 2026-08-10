# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Matches do
  describe '.by_sport_and_country_and_league_and_season' do
    subject(:matches) do
      described_class.by_sport_and_country_and_league_and_season(
        'soccer',
        'England',
        'Premier League',
        '2019/2020'
      )
    end

    before do
      stub_request(:get, 'https://www.oddsportal.com/football/')
        .to_return(status: 200, body: read_fixture('pages/football.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/')
        .to_return(status: 200, body: read_fixture('pages/england.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league/results/')
        .to_return(status: 200, body: read_fixture('pages/premier_league_results.html'))
      stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/')
        .to_return(status: 200, body: read_fixture('pages/premier_league_2019_2020_results.html'))
      stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/test-token/1/0/')
        .to_return(status: 200, body: read_fixture('archive/page_1.enc'))
      stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/test-token/1/0/page/2/')
        .to_return(status: 200, body: read_fixture('archive/page_2.enc'))
    end

    it 'resolves the season, decodes the archive, paginates, and preserves the public response shape' do
      expect(matches).to eq(
        [
          {
            match_date: '26 Jul 2020',
            match_time: '17:00',
            participants: 'Arsenal - Watford',
            score: '3:2',
            odds: { home_win: '2.00', draw: '3.80', away_win: '3.50' }
          },
          {
            match_date: '26 Jul 2020',
            match_time: '17:00',
            participants: 'Chelsea - Wolves',
            score: 'canc.',
            odds: { home_win: nil, draw: nil, away_win: nil }
          },
          {
            match_date: '25 Jul 2020',
            match_time: '17:00',
            participants: 'Manchester City - Arsenal',
            score: '3:0',
            odds: { home_win: nil, draw: nil, away_win: nil }
          }
        ]
      )
    end

    it 'uses the current football route for the soccer API' do
      matches
      expect(WebMock).to have_requested(:get, 'https://www.oddsportal.com/football/')
    end

    context 'when the season has no odds' do
      before do
        stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/')
          .to_return(
            status: 200,
            body: '<html><body><div data-testid="null-result-message">No matches available</div></body></html>'
          )
      end

      it { is_expected.to eq([]) }
    end

    context 'when the archive explicitly reports no available odds' do
      before do
        stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/')
          .to_return(status: 200, body: read_fixture('pages/premier_league_2019_2020_results.html'))
        stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/test-token/1/0/')
          .to_return(status: 200, body: read_fixture('archive/empty.enc'))
      end

      it { is_expected.to eq([]) }
    end

    context 'when the first archive response is transiently empty' do
      before do
        season_page = read_fixture('pages/premier_league_2019_2020_results.html')
        retry_season_page = season_page.sub('/1/test-token/1/0/', '/1/retry-token/1/0/')

        stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/')
          .to_return(
            { status: 200, body: season_page },
            { status: 200, body: retry_season_page }
          )
        stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/test-token/1/0/')
          .to_return(status: 200, body: read_fixture('archive/empty.enc'))
        stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/retry-token/1/0/')
          .to_return(status: 200, body: read_fixture('archive/page_1.enc'))
        stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/retry-token/1/0/page/2/')
          .to_return(status: 200, body: read_fixture('archive/page_2.enc'))
      end

      it 'refetches the season page and accepts a later non-empty archive' do
        expect(matches).to contain_exactly(
          hash_including(participants: 'Arsenal - Watford'),
          hash_including(participants: 'Chelsea - Wolves'),
          hash_including(participants: 'Manchester City - Arsenal')
        )
        expect(WebMock).to have_requested(
          :get,
          'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/'
        ).twice
      end
    end

    context 'when the archive response is malformed' do
      before do
        stub_request(:get, 'https://backend.oddsportal.com/ajax-sport-country-tournament-archive_/1/test-token/1/0/')
          .to_return(status: 200, body: 'not-an-archive')
      end

      it 'raises a protocol error' do
        expect { matches }.to raise_error(OddsportalScraper::ProtocolError, /decode/)
      end
    end

    context 'when the browser fallback is explicitly enabled', :browser_fallback do
      before do
        allow(OddsportalScraper::BrowserFallback).to receive(:enabled?).and_return(true)
        allow(OddsportalScraper::BrowserFallback::Matches).to receive(:call).and_return([{ fallback: true }])
        stub_request(:get, 'https://www.oddsportal.com/football/england/premier-league-2019-2020/results/')
          .to_return(status: 200, body: '<html><body>unexpected successful response</body></html>')
      end

      it 'delegates only after the HTTP protocol fails' do
        expect(matches).to eq([{ fallback: true }])
        expect(OddsportalScraper::BrowserFallback::Matches).to have_received(:call).with(
          sport: 'soccer',
          country: 'England',
          league: 'Premier League',
          season: '2019/2020'
        )
      end
    end
  end
end
