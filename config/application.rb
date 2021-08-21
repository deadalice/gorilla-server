require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
#require "action_mailbox/engine"
#require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
#require "sprockets/railtie"
#require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GpServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.enable_dependency_loading = true
    config.autoload_paths += %W[#{config.root}/lib]
    config.i18n.available_locales = %i[en]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [config.i18n.default_locale]
    config.active_storage.routes_prefix = "/files"
    config.active_storage.resolve_model_to_route = :rails_storage_proxy
    config.identity_cache_store = :mem_cache_store, "localhost", "localhost", {
      expires_in: 6.hours.to_i, # in case of network errors when sending a cache invalidation
      failover: false, # avoids more cache consistency issues
    }
    # TODO: Rails 7
    # config.active_record.async_query_executor = :multi_thread_pool

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
