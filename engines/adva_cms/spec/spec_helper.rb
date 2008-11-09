# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

$:.unshift File.expand_path(RAILS_ROOT + "/vendor/gems/rspec-rails-1.1.4/lib")
$:.unshift File.expand_path(RAILS_ROOT + "/vendor/gems/rspec-1.1.4/lib")

require 'spec'
require 'spec/rails'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'factories', 'factories'))


# load spec helpers
spec_helpers_dir = File.dirname(__FILE__) + '/spec_helpers'
Dir[spec_helpers_dir + '/*.rb'].sort.each do |spec_helper_file|
  require spec_helper_file
end

# load all custom matchers
matchers_dir = File.dirname(__FILE__) + '/matchers'
Dir[matchers_dir + '/*.rb'].each do |matcher_file|
  require matcher_file
end

# load stubs and scenarios
Stubby::Definition.directory = File.dirname(__FILE__) + "/stubs"
Stubby::Scenario.directory = File.dirname(__FILE__) + "/scenarios"

Stubby.load

Stubby::Stub.class_eval do
  def role_context
    self.class.role_context_class.new(self)
  end
end

# load extensions
require "cacheable_flash/test_helpers"
require "rspec_on_rails_on_crack"
# AGW::CacheTest.setup
ActionController::TestResponse.send(:include, CacheableFlash::TestHelpers)

Spec::Rails::Example::RailsExampleGroup.class_eval do
  before :each do
    I18n.default_locale = :en # reset this because it will be changed in base controllers
    I18n.locale = nil
  end
end
  
Spec::Rails::Example::ControllerExampleGroup.class_eval do
  def params_from(method, path, env = {:host_with_port => 'test.host'})
    ensure_that_routes_are_loaded
    env.merge!({:method => method})
    ActionController::Routing::Routes.recognize_path(path, env)
  end
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/'
end