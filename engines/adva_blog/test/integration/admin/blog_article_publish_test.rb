require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class BlogArticlePublishTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_blog
    login_as :admin
  end

  def test_admin_creates_and_publishes_blog_article
    # go to articles list page
    get admin_articles_path(@site, @section)
  
    # click on the "Create one now" link
    click_link "Create one now"
  
    # check that the article show page is rendered
    assert_template "admin/articles/new"
  
    # fill in the form and submit it
    fill_in 'title', :with => 'the article title'
    fill_in 'article[body]', :with =>'the article body'
    fill_in 'article[tag_list]', :with => 'foo bar'
    click_button 'Save'
  
    # check the article was created
    article = Article.first
    assert_equal 'the article title', article.title
    assert_equal 'the article body', article.body
    assert_equal %w(foo bar), article.tags.map(&:to_s)
  
    # check that we've been redirected to the admin blog articles list
    assert_template 'admin/articles/edit'
  
    # TODO won't happen. the preview is implemented this way
  
    # go to the frontend and view the article and find the article is not there
    # get article_path(@section, article.full_permalink)
    # assert_response 404
  
    # go back to the admin article edit page
    get edit_admin_article_path(@site, @section, article)
  
    # publish the article
    uncheck 'Yes, save this article as a draft'
    click_button 'Save without Revision'
  
    # go to the frontend and view the article
    get article_path(@section, article.full_permalink)
    assert_response :success
  end

  def test_admin_previews_an_unpublished_blog_article
    factory_scenario :unpublished_blog_article

    article = Factory.create :unpublished_blog_article, :author => controller.current_user
    @section.articles = [article]

    # go to article edit page
    get edit_admin_article_path(@site, @section, article)

    # click the article link
    click_link 'Preview'

    # check that the article is displayed
    assert_select "div#article_#{article.id}[class*=?]", 'entry' do
      assert_select 'a', :text => article.title
    end

    # TODO assert_page_not_cached
  end
end