require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class SectionIndexTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'

      @published_article = Article.find_by_title 'a section article'
      @unpublished_article = Article.find_by_title 'an unpublished section article'
    end
  
    test "User clicks through section frontend section index pages" do
      visits_section_index 
    end
  
    def visits_section_index
      get "/"
    
      renders_template "sections/show"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end
  end
end