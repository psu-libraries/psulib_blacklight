# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap', require: false
gem 'config'
gem 'ddtrace', '~> 0.48.0'
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.6'
gem 'faraday'
gem 'flamegraph'
gem 'high_voltage', '~> 3.1'
gem 'lcsort', '~> 0.9'
gem 'lograge'
gem 'memory_profiler'
gem 'puma', '~> 4.3'
gem 'rack-mini-profiler'
gem 'rails', '~> 6.0.4'
gem 'redis', '~> 4.2'
gem 'rsolr', '>= 1.0'
gem 'rubyzip'
gem 'shelvit'
gem 'stackprof'
gem 'webpacker'

gem 'blacklight'
gem 'blacklight_advanced_search', '~> 7.0'
gem 'blacklight-marc', '~> 7.0'
gem 'blacklight_range_limit'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'niftany', '~> 0.9'
  gem 'pry-byebug'
  gem 'sinatra'
  gem 'sqlite3'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', '< 0.18', require: false # CodeClimate does not work with .18 or later
  gem 'vcr'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end

group :production, :test do
  gem 'mysql2', '>= 0.4.4', '< 0.6.0'
end
