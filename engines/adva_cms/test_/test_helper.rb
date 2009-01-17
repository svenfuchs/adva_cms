ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

require 'matchy'
require 'test_help'
require 'with'
require 'with-sugar'

require 'webrat'
require 'webrat/rails'

require 'globalize/i18n/missing_translations_raise_handler'
I18n.exception_handler = :missing_translations_raise_handler

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  def setup_with_test_setup
    setup_without_test_setup
    start_db_transaction!
    setup_themes_dir!
    setup_assets_dir!
  end
  alias_method_chain :setup, :test_setup
  
  def teardown_with_test_setup
    teardown_without_test_setup
  ensure
    rollback_db_transaction!
    clear_themes_dir!
    clear_assets_dir!
  end
  alias_method_chain :teardown, :test_setup
end

Dir[File.dirname(__FILE__) + "/test_init/**/*.rb"].each { |path| require path }