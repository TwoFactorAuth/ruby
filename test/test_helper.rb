ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require 'devise'

Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
require_relative 'dummy/app/models/user'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
end

class ActionController::TestCase
  include Devise::TestHelpers
  include Warden::Test::Helpers
  Warden.test_mode!

  def teardown
    Warden.test_reset!
    # clear all the settings
    TwoFactorAuth.instance_variable_set(:@facet_domain, nil)
    TwoFactorAuth.instance_variable_set(:@trusted_facet_list_url, nil)
    TwoFactorAuth.instance_variable_set(:@facets, nil)
  end

  def register_as user, registration
    sign_in user
    assert_equal registration.login, user
  end

  def authenticate_as user, registration
    sign_in user
    assert_equal registration.login, user
    controller.user_session['two_factor_auth_authenticated'] = Time.now
  end

  attr_reader :controller
end
