# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Blog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "*.{rb,yml}").to_s]
    config.i18n.default_locale = :zh
    config.encoding = "utf-8"

    # Auto load lib folder
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.to_prepare do
      # Configure single controller layout
      Devise::SessionsController.layout "devise"
    end

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec, fixture: false, views: false
      g.fixture_replacement :machinist
    end
  end
end
