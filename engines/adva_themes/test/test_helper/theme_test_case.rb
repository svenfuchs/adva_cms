module ThemeTestCaseExtension#
  def self.included(base)
    base.setup    :setup_themes_dir!
    base.teardown :clear_themes_dir!
  end

  def setup_themes_dir!
    Theme.root_dir = "#{RAILS_ROOT}/tmp"
  end

  def clear_themes_dir!
    Dir["#{Theme.root_dir}/sites/*/themes"].each { |path| FileUtils.rm_r(path) }
  end
end

class ThemeTestCase < ActiveSupport::TestCase
  include ThemeTestCaseExtension
end

class ThemeViewTestCase < ActionView::TestCase
  include ThemeTestCaseExtension
end

class ThemeControllerTestCase < ActionController::TestCase
  include ThemeTestCaseExtension
end

class ThemeIntegrationTest < ActionController::IntegrationTest
  include ThemeTestCaseExtension
end