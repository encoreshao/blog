# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "database_cleaner"
require "ffaker"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.failure_color = :magenta
  config.color_mode = :on
  config.warnings = false

  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::LoggingHelpers, type: :controller
  # config.extend ViewResourceMacros, type: :view
end
