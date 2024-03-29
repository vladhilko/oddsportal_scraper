# frozen_string_literal: true

require 'oddsportal_scraper'
require 'support/fixtures'
require 'support/webmock'
require 'support/vcr'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  VCR.configure do |config|
    config.allow_http_connections_when_no_cassette = true
  end
end
