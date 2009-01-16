ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")
require 'test_help'

require File.expand_path(File.dirname(__FILE__) + "/../../../spec/webrat/lib/webrat/rails")
Webrat.configuration.open_error_files = false

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'factories', 'factories'))
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helpers', 'assertions'))
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helpers', 'integration_steps'))
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helpers', 'integration_db_reset'))
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helpers', 'remove_all_test_cronjobs'))

require 'globalize/i18n/missing_translations_raise_handler'
I18n.exception_handler = :missing_translations_raise_handler

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

ActionController::IntegrationTest.send :include, FactoryScenario

class Event
  module TestLog
    Event.observers << self
    @@events = []

    class << self
      def clear!
        @@events = []
      end

      def was_triggered?(type)
        @@events.include? type
      end

      def handle_event!(event)
        @@events ||= []
        @@events << event.type
      end
    end
  end
end

# modified the original helper
module CacheableFlash
  module TestHelpers
    def flash_cookie
      return {} unless cookies['flash']
      flash = CGI::unescape cookies['flash']
      HashWithIndifferentAccess.new JSON.parse(flash)
    end
  end
end

# TODO: verify all this code ...
Theme.root_dir = RAILS_ROOT + '/tmp'
Asset.base_dir = RAILS_ROOT + '/tmp/assets'

ActionController::IntegrationTest.class_eval do
  teardown do
    flush_page_cache!
  end
end

def enable_page_caching!
  ActionController::Base.page_cache_directory = RAILS_ROOT + '/tmp/cache'
  ActionController::Base.perform_caching = true
end

def disable_page_caching!
  if page_caching_enabled?
    flush_page_cache!
    ActionController::Base.page_cache_directory = nil
    ActionController::Base.perform_caching = false
  end
end

def page_caching_enabled?
  ActionController::Base.page_cache_directory == RAILS_ROOT + '/tmp/cache' && ActionController::Base.perform_caching
end

def flush_page_cache!
  CachedPage.delete_all
  cache_dirs = ActionController::Base.page_cache_directory, Theme.base_dir, Asset.base_dir, RAILS_ROOT + "/tmp/webrat*"
  cache_dirs.each{ |dir| FileUtils.rm_rf dir unless dir.empty? || dir == '/' }
end
# TODO: ... until here!
