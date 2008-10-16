require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

def assert_page_cached
  path = ActionController::Base.send(:page_cache_path, '/')
  get '/'
  cached_page = CachedPage.find(:first)
  assert Pathname.new(path).exist?
end

# Story: Viewing a blog index page
#   As an anonymous visitor 
#   I want to access the blog index pages
#   So I can see all the cool blog articles
class BlogIndexTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  # TODO: make caching work correctly

  def setup
    #enable_page_caching!
    #flush_page_cache!
  end

  def teardown
    #disable_page_caching!
  end

  def test_view_an_empty_blog_index_page
    Factory :site_with_blog
    Factory :unpublished_blog_article

    # go to root page
    get "/"

    # check that the page doesn't display the unpublished article
    assert_template "blog/index"
    assert_select "div#article_1", false
    assert_select "div.meta", false

    # check that the page is cached
    # assert_page_cached
  end

  def test_blog_with_an_article_that_has_an_excerpt_and_no_comments
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]

    # go to root page
    get "/"

    # check that the page shows the article ...
    assert_select "div#article_1" do
      # ... with its title ...
      assert_select "div.content>h2", /adva-cms kicks ass!/
      # ... and its excerpt ...
      assert_select "div.content", /In this article you will find proof that adva-cms really kicks ass./
      # ... and a link to the full article ...
      assert_select "div.content a", /Read the rest of this entry/
      # ... and a link to its comments ...
      assert_select "div.meta a", /0 comments/
      # ... but not its body.
      assert !(response.body === /Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!/)
      # assert_select "div.content", /Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!/
      # TODO: improve HTML markup so assert_select is easier
    end
  end
end