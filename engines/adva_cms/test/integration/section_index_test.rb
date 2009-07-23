require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class SectionIndexTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'

      @published_article = Article.find_by_title 'a page article'
      @unpublished_article = Article.find_by_title 'an unpublished page article'
    end
  
    test "User clicks through section frontend section index pages" do
      get "/"
    
      renders_template "pages/articles/index"
      has_text @published_article.title
      has_text @published_article.excerpt
      does_not_have_text @unpublished_article.title
    end
    
    test "section with non-ascii permalink is accessible" do
      section = @site.sections.find_by_permalink('page with non-ascii permalink')
      
      get "/öäü"
      renders_template "pages/articles/index"
    end
    
    # FIXME feature does not work
    # test "section with special character permalink is accessible" do
    #   section = @site.sections.find_by_permalink('$%&')
    #   
    #   get page_url(section)
    #   renders_template "pages/articles/index"
    # end
  end
end