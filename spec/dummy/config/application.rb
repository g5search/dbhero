require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)
require "dbhero"
require "slim"

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.2

    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE", "dummy_test_secret_key_base_only_used_in_specs_not_for_production")

    config.generators do |g|
      g.template_engine :slim
    end
  end
end
