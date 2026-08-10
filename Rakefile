# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--tag ~@with_chromedriver'
end

RSpec::Core::RakeTask.new(:browser_spec) do |task|
  task.rspec_opts = '--tag @with_chromedriver'
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]
