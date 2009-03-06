require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PageTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
  end

  test "Page.content_type returns 'Article'" do
    Page.content_type.should == 'Article'
  end
  
  test "a page has a single_article_mode option that returns true by default" do
    Page.new.should respond_to(:single_article_mode)
    Page.new.single_article_mode.should be_true
  end
end