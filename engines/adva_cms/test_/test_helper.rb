ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

require 'matchy'
require 'test_help'
require 'with'
require 'with-sugar'
require 'globalize/i18n/missing_translations_raise_handler'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  setup do
    start_db_transaction!
    setup_themes_dir!
    setup_assets_dir!
  end
  
  teardown do
    rollback_db_transaction!
    clear_themes_dir!
    clear_assets_dir!
  end
end

Dir[File.dirname(__FILE__) + "/test_init/**/*.rb"].each { |path| require path }

# With.aspects << :access_control

OptionParser.new do |o|
  o.on('-l', '--line=LINE', "Run tests defined at the given LINE.") do |line|
    With.options[:line] = line
  end
end.parse!(ARGV)

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
