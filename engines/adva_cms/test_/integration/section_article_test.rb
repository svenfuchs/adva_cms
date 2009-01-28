require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class SectionArticleTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'

      @published_article = Article.find_by_title 'a section article'
      @unpublished_article = Article.find_by_title 'an unpublished section article'
    
      stub(Time).now.returns Time.utc(2008, 1, 2)
    end
  
    test "User clicks through section frontend section article show pages" do
      visits_published_article_page
      visits_unpublished_article_page_as_anonymous
      visits_unpublished_article_page_as_admin
    end
  
    def visits_published_article_page
      get '/articles/a-section-article'
      renders_template "sections/show"
      displays_article @published_article
      displays_comments @published_article.approved_comments
    end
  
    def visits_unpublished_article_page_as_anonymous
      get '/articles/an-unpublished-section-article'
      assert_status 404
    end
  
    def visits_unpublished_article_page_as_admin
      login_as_admin
      get '/articles/an-unpublished-section-article'
      renders_template "sections/show"
      displays_article @unpublished_article
    end
  end
end