require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper' ))

# Story: Publishing a blog article
#   As an admin
#   I want to write blog articles in the admin area
#   So they get published in the frontend
#
# 
#   Scenario: An admin publishes a blog article
#     Given a blog with an article
#     And the user is logged in as admin
#     When the user visits the admin blog article edit page
#     And the user unchecks 'Yes, save this article as a draft'
#     And the user clicks the 'Apply changes' button
#     And the user goes to the url /
#     Then the page displays the article

class BlogArticlePublishTest < ActionController::IntegrationTest
  def setup
    Article.delete_all
    
    @site = Factory :site
    @blog = Factory :blog
    @blog.update_attributes :site => @site

    login_as :admin
  end
  
  def test_admin_creates_and_publishes_blog_article
    # go to articles list page
    get admin_articles_path(@site, @blog)
    
    # click on the "Create one now" link
    clicks_link "Create one now"
  
    # check that the article show page is rendered
    assert_template "admin/articles/new"
  
    # fill in the form and submit it
    fills_in 'title', :with => 'the article title'
    fills_in 'article[body]', :with =>'the article body'
    fills_in 'article[tag_list]', :with => 'foo bar'
    clicks_button 'Save article'
    
    # check the article was created
    article = Article.first
    assert_equal 'the article title', article.title
    assert_equal 'the article body', article.body
    assert_equal %w(foo bar), article.tags.map(&:to_s)
    
    # check that we've been redirected to the admin blog articles list
    assert_template 'admin/articles/edit'

    # TODO won't happen. the preview is implemented this way
    
    # go to the frontend and view the article and find the article is not there
    # get article_path(@blog, article.full_permalink)
    # assert_response 404
    
    # go back to the admin article edit page
    get edit_admin_article_path(@site, @blog, article)
    
    # publish the article
    unchecks 'Yes, save this article as a draft'
    clicks_button 'Save without Revision'
    
    # go to the frontend and view the article
    get article_path(@blog, article.full_permalink)
    assert_response :success
  end
  
  def test_admin_previews_an_unpublished_blog_article
    article = Factory.create :unpublished_blog_article, :author => controller.current_user
    @blog.articles = [article]
    
    # go to article edit page
    get edit_admin_article_path(@site, @blog, article)
  
    # click the article link
    clicks_link 'Preview'
  
    # check that the article is displayed
    assert_select "div#article_#{article.id}[class*=?]", 'entry' do
      assert_select 'a', :text => article.title
    end
    
    # TODO assert_page_not_cached
  end
end