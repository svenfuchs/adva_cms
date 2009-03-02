defined?(ASSET_TEST_HELPER_LOADED) ? raise("can not load #{__FILE__} twice") : ASSET_TEST_HELPER_LOADED = true

require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

class Test::Unit::TestCase
  def setup_with_adva_assets_setup
    setup_without_adva_assets_setup
    setup_assets_dir!
  end
  alias_method_chain :setup, :adva_assets_setup

  def teardown_with_adva_assets_setup
    teardown_without_adva_assets_setup
  ensure
    clear_assets_dir!
  end
  alias_method_chain :teardown, :adva_assets_setup
end