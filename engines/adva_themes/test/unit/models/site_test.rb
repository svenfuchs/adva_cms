require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SiteTest < ActiveSupport::TestCase
  test 'has many themes' do
    Site.should have_many_themes
  end
end