# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::HttpClient do
  it 'retries transient server responses before returning the successful response' do
    request = stub_request(:get, 'https://example.test/archive')
              .to_return(status: 503, body: 'busy')
              .then.to_return(status: 200, body: 'ok')

    response = described_class.new(max_retries: 1, retry_delay: 0).get('https://example.test/archive')

    expect(response.body).to eq('ok')
    expect(request).to have_been_requested.times(2)
  end

  it 'raises a transport error with the response status' do
    stub_request(:get, 'https://example.test/missing').to_return(status: 404, body: '')

    expect { described_class.new.get('https://example.test/missing') }
      .to raise_error(OddsportalScraper::TransportError) { |error| expect(error.status).to eq(404) }
  end

  it 'raises a transport error for an invalid URL' do
    expect { described_class.new.get('not a URL') }
      .to raise_error(OddsportalScraper::TransportError, /request URL is invalid/)
  end
end
