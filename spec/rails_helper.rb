ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "factory_bot"
require "factories"
require "shoulda/matchers"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
