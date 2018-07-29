# frozen_string_literal: true

#
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "components")

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.compile = true

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')
# Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

Rails.application.config.serve_static_assets = false

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[admin.js admin.css devise.css pages.js pages.css]
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
