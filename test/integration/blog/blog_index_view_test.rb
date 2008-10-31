require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

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
    assert_page_cached
  end
  
  def test_view_a_blog_with_an_article_that_has_an_excerpt_and_no_comments
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
      assert response.body !~ /Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!/
      # TODO: improve HTML markup so assert_select is easier
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_a_blog_with_an_article_that_does_not_have_an_excerpt
    site = Factory :site_with_blog
    article = Factory.build(:published_blog_article, :excerpt => nil)
    site.sections.first.articles = [article]
  
    # go to root page
    get "/"
  
    # check that the page shows the article ...
    assert_select "div#article_1" do
      # ... with its title ...
      assert_select "div.content>h2", /adva-cms kicks ass!/
      # ... and its body ...
      assert_select "div.content", /Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!/
      # ... but not its excerpt ...
      assert response.body !~ /In this article you will find proof that adva-cms really kicks ass./
      # ... and not a link to the full article ...
      assert response.body !~ /Read the rest of this entry/
      # TODO: improve HTML markup so assert_select is easier
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  # TODO: cleanup
  def test_view_a_blog_that_has_an_article_with_one_approved_comment
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    comment = Factory.build(:approved_comment, :commentable_type => "Article", :commentable_id => article.id, :author => article.author)
    comment.save!
    site.sections.first.articles = [article]
  
    # go to root page
    get "/"
  
    # check that the page shows "1 comment"
    assert_select "div.meta a", "1 comment"
  
    # check that the page is cached
    assert_page_cached
  end
  
  # TODO: cleanup
  def test_view_a_blog_that_has_an_article_with_one_unapproved_comment
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    comment = Factory.build(:unapproved_comment, :commentable_type => "Article", :commentable_id => article.id, :author => article.author)
    comment.save!
    site.sections.first.articles = [article]
  
    # go to root page
    get "/"
  
    # check that the page shows "0 comments"
    assert_select "div.meta a", "0 comments"
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_a_category_with_no_articles
    Factory :published_blog_article
  
    # go to category show page
    get "/categories/private-rantings"
  
    # TODO: shouldn't we check here that the category page is displayed?
  
    # check that the page doesn't show the article
    assert response.body !~ /adva-cms kicks ass!/
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_a_category_with_one_article
    site = Factory :site_with_blog
    article = Factory.build(:published_blog_article, :categories => [Factory.build(:category, :section => site.sections.first)])
    site.sections.first.articles = [article]
  
    # go to category show page
    get "/categories/general-information"
  
    # TODO: shouldn't we check here that the category page is displayed?
  
    # check that the page shows the article
    assert_select "div.content h2", "adva-cms kicks ass!"
  
    # check that the page is cached
    assert_page_cached
  end

  def test_view_a_tag_with_one_article
    site = Factory :site_with_blog
    article = Factory.build(:published_blog_article, :tags => [Factory(:tag_rails)])
    site.sections.first.articles = [article]
  
    # go to tag show page
    get "/tags/rails"
  
    # TODO: shouldn't we check here that the tag page is displayed?
  
    # check that the page shows the article
    assert_select "div.content h2", "adva-cms kicks ass!"
  
    # check that the page is cached
    assert_page_cached
  end

  def test_view_a_tag_with_no_article
    site = Factory :site_with_blog
    tag_java = Factory(:tag_java) # needs to exist
    article = Factory.build(:published_blog_article, :tags => [Factory(:tag_rails)])
    site.sections.first.articles = [article]
  
    # go to tag show page
    get "/tags/java"

    # check that the tag page is displayed
    assert response.body =~ /Articles tagged java/
  
    # check that the page doesn't show the article
    assert response.body !~ /adva-cms kicks ass!/
  
    # check that the page is cached
    assert_page_cached
  end

  def test_view_a_tag_with_an_unrelated_article
    site = Factory :site_with_blog
    article_1 = Factory.build(:published_blog_article, :tags => [Factory(:tag_rails)])
    article_2 = Factory.build(:published_blog_article, :title => 'title java', :tags => [Factory(:tag_java)])
    site.sections.first.articles = [article_1, article_2]
  
    # go to tag show page
    get "/tags/rails"

    # check that the tag page is displayed
    assert response.body =~ /Articles tagged rails/
  
    # check that the page doesn't show the article
    assert response.body !~ /title java/
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_year_archive_with_no_articles
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to the year archive page
    get "/2007"
  
    # check that the page doesn't show the article
    assert response.body !~ /adva-cms kicks ass!/
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_year_archive_with_one_article
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to the year archive page
    get "/2008"
  
    # check that the page shows the article
    assert_select "div.content h2", "adva-cms kicks ass!"
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_month_archive_with_no_articles
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to the month archive page
    get "/2008/9"
  
    # check that the page doesn't show the article
    assert response.body !~ /adva-cms kicks ass!/
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_momth_archive_with_one_article
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to the month archive page
    get "/2008/10"
  
    # check that the page shows the article
    assert_select "div.content h2", "adva-cms kicks ass!"
  
    # check that the page is cached
    assert_page_cached
  end
end