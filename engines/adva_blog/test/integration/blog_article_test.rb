require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class BlogArticleTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'

      @published_article = Article.find_by_title 'a blog article'
      @unpublished_article = Article.find_by_title 'an unpublished blog article'
    
      stub(Time).now.returns Time.utc(2008, 1, 2)
    end
  
    test "User clicks through blog frontend blog article show pages" do
      visits_published_article_page
      visits_unpublished_article_page_as_anonymous
      visits_unpublished_article_page_as_admin
    end
  
    def visits_published_article_page
      get '/2008/1/1/a-blog-article'
      renders_template "blogs/articles/show"
      displays_article @published_article
      displays_comments @published_article.approved_comments
    end
  
    def visits_unpublished_article_page_as_anonymous
      get '/2008/1/1/an-unpublished-blog-article'
      assert_status 404
    end
  
    def visits_unpublished_article_page_as_admin
      login_as_superuser
      get '/2008/1/1/an-unpublished-blog-article'
      renders_template "blogs/articles/show"
      displays_article @unpublished_article
    end
  end
end