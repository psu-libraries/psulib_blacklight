# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap', require: false
gem 'bot_challenge_page', '~> 0.3.1'
gem 'bugsnag', '~> 6.26'
gem 'config'
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.8.3'
gem 'faraday', '~>1.10'
gem 'flamegraph'
gem 'high_voltage', '~> 3.1'
gem 'lcsort', '~> 0.9'
gem 'lograge'
gem 'memory_profiler'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'okcomputer', '~> 1.18'
gem 'puma', '~> 6.5'
gem 'rack-mini-profiler'
gem 'rails', '~> 7.1.0'
gem 'rsolr', '>= 2.5'
gem 'rubyzip'
gem 'shakapacker', '= 7.1'
gem 'shelvit'
gem 'sprockets-rails'
gem 'stackprof'

gem 'blacklight', '~> 7.35'
gem 'blacklight_advanced_search', '~> 8.0.0.alpha'
gem 'blacklight-marc', '~> 8.0'
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
  gem 'html_tokenizer', '~> 0.0.8'
  gem 'niftany', '~> 0.10'
  gem 'pry-byebug'
  gem 'sinatra'
  gem 'sqlite3', '~> 1.5.0'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :production, :test do
  gem 'mysql2', '>= 0.5.6', '< 0.6.0'
end
