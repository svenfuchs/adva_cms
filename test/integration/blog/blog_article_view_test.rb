require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

# Story: Viewing a blog article page
#   As an anonymous visitor
#   I want to access the blog article page
#   So I can read the full article
class BlogArticleViewTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  # TODO: make caching work correctly

  def setup
    #enable_page_caching!
    #flush_page_cache!
  end

  def test_view_blog_article_page
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows the article ...
    assert_select "div#article_1" do
      # ... with its title ...
      assert_select "div.content>h2", /adva-cms kicks ass!/
      # ... and its excerpt ...
      assert_select "div.content", /In this article you will find proof that adva-cms really kicks ass./
      # ... and its body ...
      assert_select "div.content", /Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!/
      # ... but not the link to the full article.
      assert response.body !~ /Read the rest of this entry/
      # TODO: improve HTML markup so assert_select is easier
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_when_commenting_is_allowed
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows a comment form
    assert_select "div#comment_form"
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_when_commenting_is_not_allowed
    site = Factory :site_with_blog
    article = Factory.build(:published_blog_article, :comment_age => -1)
    # TODO: maybe make some kind of virtual boolean flag? article.allow_comments? => true/false; article.allow_comments = true/false
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows a comment form
    assert_select "div#comment_form", false, "The page should not contain a comment form."
  
    # check that the page is cached
    assert_page_cached
  end
  
  # TODO: cleanup
  def test_view_blog_article_page_with_one_approved_comment
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    comment = Factory.build(:approved_comment, :commentable_type => "Article", :commentable_id => article.id, :author => article.author)
    comment.save!
    article.comments = [comment]
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that page shows that there is 1 comment
    assert_select "div#comments h2", "1 Comment"
  
    # check that the page shows the comment ...
    assert_select "li#comment_1" do
      # ... with its body.
      assert_select "div.comment", { :text => /Yes, I think that's a very good idea./ }
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_with_one_unapproved_comment
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    comment = Factory.build(:unapproved_comment, :commentable_type => "Article", :commentable_id => article.id, :author => article.author)
    comment.save!
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that page doesn't show are comments
    assert_select "div#comments h2", false, "The page shouldn't show that there are comments."
  
    # check that the page doesn't show the comment
    assert_select "li#comment_1", false, "The page shouldn't show the unapproved comment."
  
    # check that the page is cached
    assert_page_cached
  end

  def test_view_blog_article_page_for_an_unpublished_article
    site = Factory :site_with_blog
    article = Factory :unpublished_blog_article
    site.sections.first.articles = [article]

    # go to article show page
    get "/2008/10/16/typo3-is-too-hard-to-use"

    # check that response is 404
    assert_response 404

    # check that the page is not cached
    assert_not_page_cached
  end

  def test_view_blog_article_page_for_a_non_existent_article
    # go to article show page
    get "/2008/10/16/django-is-pretty-cool"
  
    # check that the request returns a 404
    assert_response 404
  
    # check that the page is not cached
    assert_not_page_cached
  end
  
  def test_view_blog_article_with_permissions_to_edit_article
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
  
    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"
    
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows the edit link
    edit_link = "/admin/sites/#{site.id}/sections/#{article.section.id}/articles/#{article.id}/edit"
    assert_select "span.visible-for", true, "The page should contain authorized span." do
      assert_select "a[href$='edit']", true, "The page should contain the edit link."
    end
  
    # check that the page is cached
    assert_page_cached
  end
end