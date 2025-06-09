# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'webmock/rspec'
require 'factory_bot_rails'

# Disable external HTTP requests during testing
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Remove this line to enable support for ActiveRecord
  config.use_active_record = false

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Clean MongoDB between tests
  config.before(:each) do
    Message.delete_all
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
