# frozen_string_literal: true

source "https://rubygems.org"
# source 'https://ruby.taobao.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.1"
# For action cache
gem "actionpack-action_caching"
# Use postgresql as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma"
# Use SCSS for stylesheets
gem "sass-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier"
# See https://github.com/rails/execjs#readme for more supported runtimes
gem "mini_racer", platforms: :ruby

gem "bootstrap"
gem "carrierwave"
gem "devise"
gem "inherited_resources"
gem "jquery-rails"
gem "kaminari"
gem "trix"
gem "simple_form"
gem "mini_magick"
# gem 'rails-i18n'

gem "redcarpet"
gem "rouge"

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "haml-rails"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "annotate"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "capybara"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop"
end

group :test do
  gem "database_cleaner"
  gem "ffaker"
  gem "machinist"
  gem "rspec-rails"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "web-console"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen"
  gem "sprockets"

  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rails-console"
  gem "capistrano-rvm"
  gem "capistrano-yarn"
  gem "capistrano3-puma"

  gem "guard-livereload", require: false
  gem "rack-livereload"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Rack middleware for blocking & throttling abusive requests
gem "rack-attack"
