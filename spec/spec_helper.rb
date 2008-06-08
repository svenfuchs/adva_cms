# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

require File.dirname(__FILE__) + '/spec_helpers/spec_controller_helper'
require File.dirname(__FILE__) + '/spec_helpers/spec_model_helper'
require File.dirname(__FILE__) + '/spec_helpers/spec_view_helper'
require File.dirname(__FILE__) + "/spec_helpers/spec_theme_helper"
require File.dirname(__FILE__) + "/spec_helpers/spec_resource_path_helper"
require File.dirname(__FILE__) + "/spec_helpers/spec_page_caching_helper"

require File.dirname(__FILE__) + "/matchers/url_matchers"
require File.dirname(__FILE__) + "/matchers/class_extensions"

Stubby::Loader.load

require "cacheable_flash/test_helpers"
require "rspec_on_rails_on_crack"
# AGW::CacheTest.setup

ActionController::TestResponse.send :include, CacheableFlash::TestHelpers

Spec::Rails::Example::ControllerExampleGroup.class_eval do
  def params_from(method, path, env = {:host_with_port => 'test.host'})
    ensure_that_routes_are_loaded
    env.merge!({:method => method})
    ActionController::Routing::Routes.recognize_path(path, env)
  end
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end