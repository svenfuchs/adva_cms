require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

class ActiveSupport::TestCase
  setup    :setup_themes_dir!
  teardown :clear_themes_dir!
end