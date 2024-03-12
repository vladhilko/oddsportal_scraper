# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
end

RSpec.configure do |config|
  config.around(:example, :vcr) do |example|
    VCR.use_cassette(example.metadata[:vcr]) { example.run }
  end
end
