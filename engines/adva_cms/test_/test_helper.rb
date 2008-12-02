ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

# require 'context'
require 'matchy'
require 'test_help'

require 'globalize/i18n/missing_translations_raise_handler'

Dir[File.dirname(__FILE__) + "/test_helper/**/*.rb"].each { |path| require path }

class Test::Unit::TestCase
  include With
  include RR::Adapters::TestUnit
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  # before :each do
  #   RR.reset
  # end
  # 
  # after :each do
  #   RR.verify
  # end
end

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

# # TODO: verify all this code ...
# Theme.root_dir = RAILS_ROOT + '/tmp'
# Asset.base_dir = RAILS_ROOT + '/tmp/assets'
# 
# 
# def enable_page_caching!
#   ActionController::Base.page_cache_directory = RAILS_ROOT + '/tmp/cache'
#   ActionController::Base.perform_caching = true
# end
# 
# def disable_page_caching!
#   if page_caching_enabled?
#     flush_page_cache!
#     ActionController::Base.page_cache_directory = nil
#     ActionController::Base.perform_caching = false
#   end
# end
# 
# def page_caching_enabled?
#   ActionController::Base.page_cache_directory == RAILS_ROOT + '/tmp/cache' && ActionController::Base.perform_caching
# end
# 
# def flush_page_cache!
#   if page_caching_enabled?
#     CachedPage.delete_all
#     cache_dirs = ActionController::Base.page_cache_directory, Theme.base_dir, Asset.base_dir, RAILS_ROOT + "/tmp/webrat*"
#     cache_dirs.each{ |dir| FileUtils.rm_rf dir unless dir.empty? || dir == '/' }
#   end
# end
# # TODO: ... until here!
