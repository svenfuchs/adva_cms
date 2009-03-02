require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module WikiTests
  class ContentHelperTest < ActionView::TestCase
    include ContentHelper
    include WikiHelper

    test "#content_path given the content's section is a Wiki it returns an wikipage_path" do
      @wikipage = Wiki.first.wikipages.second
      content_path(@wikipage).should =~ %r(/pages/another-wikipage)
    end
  end
end