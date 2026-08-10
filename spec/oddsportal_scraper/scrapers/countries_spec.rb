# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Countries do
  describe '.by_sport' do
    subject(:countries) { described_class.by_sport(sport) }

    let(:sport) { 'soccer' }

    before do
      stub_request(:get, 'https://www.oddsportal.com/football/')
        .to_return(status: 200, body: read_fixture('pages/football.html'))
    end

    it 'translates soccer to the current football route and returns visible countries' do
      expect(countries).to contain_exactly('England', 'Spain')
      expect(WebMock).to have_requested(:get, 'https://www.oddsportal.com/football/')
    end

    context 'when the sport page is not found' do
      before do
        stub_request(:get, 'https://www.oddsportal.com/football/')
          .to_return(status: 404, body: '')
      end

      it { is_expected.to eq([]) }
    end

    context 'when a successful page has no country links' do
      before do
        stub_request(:get, 'https://www.oddsportal.com/football/')
          .to_return(status: 200, body: '<html><body>challenge</body></html>')
      end

      it 'raises a protocol error instead of silently succeeding' do
        expect { countries }.to raise_error(OddsportalScraper::ProtocolError, /no country links/)
      end
    end
  end
end
