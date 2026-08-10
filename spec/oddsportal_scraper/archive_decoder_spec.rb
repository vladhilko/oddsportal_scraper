# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::ArchiveDecoder do
  it 'decodes the encrypted gzip archive fixture' do
    decoded = described_class.decode(read_fixture('archive/page_1.enc'))

    expect(decoded.dig('d', 'rows', 0, 'home-name')).to eq('Arsenal')
    expect(decoded.dig('d', 'rows', 0, 'odds', 1, 'avgOdds')).to eq(3.8)
  end

  it 'raises a protocol error for an invalid response' do
    expect { described_class.decode('invalid') }
      .to raise_error(OddsportalScraper::ProtocolError, /decode/)
  end
end
