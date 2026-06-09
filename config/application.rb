require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ladsv3
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.i18n.default_locale = :fr
    config.time_zone = 'Europe/Paris'

    # The Public V2 exploded-view renderer is a manually required drawing engine:
    # each file groups several geometry/value objects instead of one Zeitwerk
    # constant. Keep it out of eager loading so production boot stays strict for
    # the rest of the app without forcing noisy placeholder constants here.
    initializer "ladsv3.ignore_public_v2_exploded_view_from_zeitwerk", before: :setup_main_autoloader do
      Rails.autoloaders.main.ignore(root.join("app/components/public_v2/products/exploded_view"))
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
