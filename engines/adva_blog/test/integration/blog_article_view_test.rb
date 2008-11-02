require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

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
    factory_scenario :published_blog_article
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows the article ...
    assert_select "div#article_1" do
      # ... with its title ...
      assert_select "div.content>h2", /#{@article.title}/
      # ... and its excerpt ...
      assert_select "div.content", /#{@article.excerpt}/
      # ... and its body ...
      assert_select "div.content", /#{@article.body}/
      # ... but not the link to the full article.
      assert response.body !~ /Read the rest of this entry/
      # TODO: improve HTML markup so assert_select is easier
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_when_commenting_is_allowed
    factory_scenario :published_blog_article
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows a comment form
    assert_select "div#comment_form"
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_where_commenting_is_not_allowed
    factory_scenario :published_blog_article
    @article.update_attributes :comment_age => -1
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
    # check that the article show page is rendered
    assert_template "blog/show"
  
    # check that the page shows a comment form
    assert_select "div#comment_form", false, "The page should not contain a comment form."
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_with_one_approved_comment
    factory_scenario :published_blog_article, :approved_article_comment
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
    # check that the article show page is rendered
    assert_template "blog/show"

    # check that page shows that there is 1 comment
    assert_select "div#comments h2", "1 Comment"
  
    # check that the page shows the comment ...
    assert_select "li#comment_1" do
      # ... with its body.
      assert_select "div.comment", { :text => /#{@comment.body}/ }
    end
  
    # check that the page is cached
    assert_page_cached
  end
  
  def test_view_blog_article_page_with_one_unapproved_comment
    factory_scenario :published_blog_article, :unapproved_article_comment
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
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
    factory_scenario :unpublished_blog_article
  
    # go to article show page
    get article_path(@section, @article.full_permalink)
  
    # check that response is 404
    assert_response 404
  
    # check that the page is not cached
    assert_not_page_cached
  end
  
  def test_view_blog_article_page_for_a_non_existent_article
    factory_scenario :site_with_a_blog

    # go to article show page
    get "/2008/10/16/django-is-pretty-cool"
  
    # check that the request returns a 404
    assert_response 404
  
    # check that the page is not cached
    assert_not_page_cached
  end
  
  def test_preview_blog_article_with_permissions_to_edit_article 
    factory_scenario :published_blog_article
    login_as :admin

    # go to article show page
    get article_path(@section, @article.full_permalink)

    # check that the article show page is rendered
    assert_template "blog/show"
    
    # edit link should be visible for only certain people
    admin       = "site-#{@site.id}-admin"
    moderator   = "section-#{@section.id}-moderator"
    owner       = "content-#{@article.id}-owner"
    visible_for = "visible-for #{moderator} #{admin} #{owner} superuser"

    # check that the page shows the edit link
    assert_select "span[class=?]", visible_for, true, "The page should contain authorized span for #{visible_for}." do
      assert_select "a[href$='edit']", true, "The page should contain the edit link."
    end
  
    # TODO check that the page is NOT cached
    # assert_page_cached
  end
end