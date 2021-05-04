# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap', require: false
gem 'config'
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.6'
gem "ddtrace", "~> 0.48.0"
gem 'faraday'
gem 'high_voltage', '~> 3.1'
gem 'lograge'
gem 'puma', '~> 3.12'
gem 'rails', '~> 6.0.3'
gem 'rsolr', '>= 1.0'
gem 'rubyzip'
gem 'webpacker'

gem 'blacklight'
gem 'blacklight_advanced_search', '~> 7.0'
gem 'blacklight-marc', '~> 7.0'
gem 'blacklight_range_limit'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman', '~> 0.63.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'niftany', '~> 0.9'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', '< 0.18', require: false # CodeClimate does not work with .18 or later
  gem 'sinatra'
  gem 'sqlite3'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end

group :production, :test do
  gem 'mysql2', '>= 0.4.4', '< 0.6.0'
end
