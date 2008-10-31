require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper' ))

# Story: Deleting a blog article
#   As an admin
#   I want to delete a blog article in the admin area
#   So that the article is removed from the system
# 
#   Scenario: An admin deletes a blog article
#     Given a blog with an article
#     And the user is logged in as admin
#     When the user visits the admin blog article edit page
#     And the user clicks on 'Delete this article'
#     Then the user is redirected to the admin blog articles page
#     And the article is deleted

class BlogArticleDeleteTest < ActionController::IntegrationTest
  def setup
    Site.delete_all
    Section.delete_all
    Content.delete_all
    User.delete_all

    @site = Factory :site
    @blog = Factory :blog
    @article = Factory :published_blog_article
    
    @blog.update_attributes :site => @site
    @blog.articles = [@article]
    
    @article.update_attributes :site => @site

    login_as :admin
  end

  def test_admin_deletes_blog_article
    # go to article show page
    get edit_admin_article_path(@site, @blog, @article)

    # check that the article show page is rendered
    assert_template "admin/articles/edit"

    # delete the article
    clicks_link "Delete this article"

    # check that the article was deleted
    assert_raise ActiveRecord::RecordNotFound do
      Article.find @article.id
    end
    
    # check that we've been redirected to the admin blog articles list
    assert_template 'admin/blog/index'
  end
end