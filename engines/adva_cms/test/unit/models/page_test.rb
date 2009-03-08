require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PageTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    @page = Page.find_by_permalink 'a-page'
  end

  test "Page.content_type returns 'Article'" do
    Page.content_type.should == 'Article'
  end
  
  test "a page has a single_article_mode option that returns true by default" do
    Page.new.should respond_to(:single_article_mode)
    Page.new.single_article_mode.should be_true
  end

  # articles association
  
  test "articles#primary returns the topmost published article" do
    @page.articles.primary.should == Article.find_by_permalink('a-page-article')
  end

  test "articles#permalinks returns the permalinks of all published articles" do
    @page.articles.permalinks.should == ['a-page-article']
  end
end