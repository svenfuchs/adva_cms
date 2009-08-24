require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PageTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    @page = Page.find_by_permalink('a-page')
  end

  test "Page.content_type returns 'Article'" do
    Page.content_type.should == 'Article'
  end

  test "a page has a single_article_mode option that returns true by default" do
    Page.new.should respond_to(:single_article_mode)
    Page.new.should be_in_single_article_mode
  end

  # articles association

  test "articles#primary returns the topmost published article" do
    @page.articles.primary.should == Article.find_by_permalink('a-page-article')
  end

  # PUBLIC INSTANCE METHODS
  test "#published?, published_at and published_at= are delegated to article (single article mode)" do
    parent_section = Page.new(:site => @site, :single_article_mode => false)
    parent_section.save(false)
    page = Page.new(:site => @site)
    page.save(false)
    page.move_to_child_of(parent_section)
    article = page.articles.build(:published_at => nil)

    article.should_not be_published
    page.should_not be_published
    page.published_at.should be_nil

    article.published_at = Time.local(2009, 5, 19, 12, 0, 0)
    article.should be_published
    page.should be_published
    page.published_at.should == Time.local(2009, 5, 19, 12, 0, 0)

    page.published_at = Time.local(2009, 5, 19, 14, 0, 0)
    article.published_at.should == Time.local(2009, 5, 19, 14, 0, 0)

    page.published_at = nil
    page.should_not be_published
    article.should_not be_published
  end

  test "#published? is false if any ancestor section is not published (single article mode)" do
    parent_section = Page.new(:site => @site, :published_at => nil)
    parent_section.save(false)
    # TODO: nested set bug?
    # section = Page.new(:site => @site, :parent => parent_section, :published_at => 2.days.ago, :single_article_mode => false)
    page = Page.new(:site => @site)
    page.save(false)
    page.move_to_child_of(parent_section)
    article = page.articles.build(:published_at => 2.days.ago)

    page.published?(true).should be_false
  end
end