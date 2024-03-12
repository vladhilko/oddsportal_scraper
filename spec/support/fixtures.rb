# frozen_string_literal: true

def parse_json_fixture(path, symbolize_names: true)
  file_path = File.join(fixture_path, path)
  JSON.parse(File.read(file_path), symbolize_names:)
end

def fixture_path
  File.join(OddsportalScraper::ROOT_DIR, 'spec/fixtures')
end
