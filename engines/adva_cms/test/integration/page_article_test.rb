require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class PageArticleTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @page = @site.sections.root

      @published_article = Article.find_by_title 'a page article'
      @unpublished_article = Article.find_by_title 'an unpublished page article'
    
      stub(Time).now.returns Time.utc(2008, 1, 2)
    end
  
    test "User clicks through page frontend page article show pages (single-article-mode)" do
      @page.single_article_mode = true
      @page.save!
      
      visit_homepage_with_single_article
      visit_published_article_page
      visit_unpublished_article_page_as_anonymous
      visit_unpublished_article_page_as_admin
    end
  
    test "User clicks through page frontend page article show pages (multi-article-mode)" do
      @page.single_article_mode = false
      @page.save!
      
      visit_homepage_with_article_list
      visit_published_article_page
      visit_unpublished_article_page_as_anonymous
      visit_unpublished_article_page_as_admin
    end
    
    test "article with non-ascii permalink is accessible" do
      article = Content.find_by_title('a page with non ascii permalink')
      
      get 'letter-test/articles/öäü'
      renders_template "pages/articles/show"
      assert_select 'div.body', Regexp.new(article.body)
    end
    
    test "article with special character permalink is accessible" do
      article = Content.find_by_title('a page with special character permalink')
      
      get 'letter-test/articles/$%&'
      renders_template "pages/articles/show"
      assert_select 'div.body', Regexp.new(article.body)
    end
  
    def visit_homepage_with_single_article
      get '/'
      renders_template "pages/articles/show"
      has_text @published_article.title
      has_text @published_article.excerpt
      has_text @published_article.body
    end
  
    def visit_homepage_with_article_list
      get '/'
      renders_template "pages/articles/index"
      has_tag 'a', @published_article.title, :href => '/articles/a-page-article'
      has_text @published_article.excerpt
      does_not_have_text @published_article.body
    end
  
    def visit_published_article_page
      get '/articles/a-page-article'
      renders_template "pages/articles/show"
      displays_article @published_article
      displays_comments @published_article.approved_comments
    end
  
    def visit_unpublished_article_page_as_anonymous
      get '/articles/an-unpublished-page-article'
      assert_status 404
    end
  
    def visit_unpublished_article_page_as_admin
      login_as_admin
      get '/articles/an-unpublished-page-article'
      renders_template "pages/articles/show"
      displays_article @unpublished_article
    end
  end
end