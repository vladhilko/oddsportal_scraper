# frozen_string_literal: true

require_relative 'lib/oddsportal_scraper/version'

Gem::Specification.new do |spec|
  spec.name = 'oddsportal_scraper'
  spec.version = OddsportalScraper::VERSION
  spec.authors = ['Vladislav Hilko']
  spec.email = ['vladislav.spawn@gmail.com']

  spec.summary = 'Read sports data from the current OddsPortal web application'
  spec.homepage = 'https://github.com/vladhilko/oddsportal_scraper'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 4.0.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.19'
  spec.add_dependency 'tzinfo', '~> 2.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
