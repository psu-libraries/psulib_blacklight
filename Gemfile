source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'coveralls', require: false
gem "rails", "~> 5.2"
gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.5'
gem 'webpacker', '~> 3.5'
gem 'bootstrap', '~> 4.0'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem "bootsnap", require: false
gem 'rsolr', '>= 1.0'

gem 'blacklight', '>= 7.0.0.rc1', github: 'projectblacklight/blacklight'
gem 'blacklight-marc', github: 'cdmo/blacklight-marc'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "foreman", "~> 0.63.0"
end

group :development, :test do
  gem 'solr_wrapper', github: 'cbeer/solr_wrapper', branch: 'master'
  gem "traject", "~> 2.3"
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :production do
  gem "mysql2", ">= 0.4.4", "< 0.6.0"
end