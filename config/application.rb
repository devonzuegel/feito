require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsOmniauth
  # config/application.rb
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,           # generate a fixture for each model
                       view_specs: false,        # skip generating view specs
                       helper_specs: false,      # skip generating specs for controller helper
                       routing_specs: true,      # generate a spec file for config/routes.rb
                       controller_specs: false,
                       request_specs: false

      # generate factories instead of fixtures
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to
    # this zone. Run "rake -D time" for a list of tasks for finding time zone names.
    # Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml
    # are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
    Dir[File.join(Rails.root, %w(lib core_ext *.rb))].each { |l| require l }

    require 'utils'
    require 'icloud'

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
