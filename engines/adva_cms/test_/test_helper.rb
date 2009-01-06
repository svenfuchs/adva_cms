ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

require 'matchy'
require 'test_help'
require 'with'
require 'with-sugar'
require 'globalize/i18n/missing_translations_raise_handler'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.fixture_path = File.dirname(__FILE__) +  '/test_helper/fixtures'
  fixtures :all
  
  setup do 
    Sham.reset
  end
  
  teardown do
    theme_root = "#{RAILS_ROOT}/tmp/themes"
    FileUtils.rm_r theme_root if File.exists?(theme_root)
  end
end

Dir[File.dirname(__FILE__) + "/test_helper/**/*.rb"].each { |path| require path }

# With.aspects << :access_control

OptionParser.new do |o|
  o.on('-l', '--line=LINE', "Run tests defined at the given LINE.") do |line|
    With.options[:line] = line
  end
end.parse!(ARGV)

Theme.root_dir = "#{RAILS_ROOT}/tmp"
Asset.base_dir = RAILS_ROOT + '/tmp/assets'
FileUtils.mkdir(Theme.root_dir) unless File.exists?(Theme.root_dir)


# ActionController::IntegrationTest.send :include, FactoryScenario
# 
# class Event
#   module TestLog
#     Event.observers << self
#     @@events = []
# 
#     class << self
#       def clear!
#         @@events = []
#       end
# 
#       def was_triggered?(type)
#         @@events.include? type
#       end
# 
#       def handle_event!(event)
#         @@events ||= []
#         @@events << event.type
#       end
#     end
#   end
# end
