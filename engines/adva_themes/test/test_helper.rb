require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

class Test::Unit::TestCase
  def setup_with_adva_themes_setup
    setup_without_adva_themes_setup
    setup_themes_dir!
  end
  alias_method_chain :setup, :adva_themes_setup

  def teardown_with_adva_themes_setup
    teardown_without_adva_themes_setup
  ensure
    clear_themes_dir!
  end
  alias_method_chain :teardown, :adva_themes_setup
end