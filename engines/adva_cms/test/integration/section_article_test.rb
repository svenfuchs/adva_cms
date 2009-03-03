require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class SectionArticleTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'

      @published_article = Article.find_by_title 'a page article'
      @unpublished_article = Article.find_by_title 'an unpublished page article'
    
      stub(Time).now.returns Time.utc(2008, 1, 2)
    end
  
    test "User clicks through page frontend page article show pages" do
      visits_published_article_page
      visits_unpublished_article_page_as_anonymous
      visits_unpublished_article_page_as_admin
    end
  
    def visits_published_article_page
      get '/articles/a-page-article'
      renders_template "pages/articles/show"
      displays_article @published_article
      displays_comments @published_article.approved_comments
    end
  
    def visits_unpublished_article_page_as_anonymous
      get '/articles/an-unpublished-page-article'
      assert_status 404
    end
  
    def visits_unpublished_article_page_as_admin
      login_as_admin
      get '/articles/an-unpublished-page-article'
      renders_template "pages/articles/show"
      displays_article @unpublished_article
    end
  end
end