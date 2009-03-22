require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class WikiTest < ActionController::IntegrationTest
    def setup
      super
      @section = Wiki.find_by_title 'a wiki'
      @site = use_site! @section.site
      @section.wikipages.delete_all
    end
    
    # FIXME specify what happens when an anonymous user views the empty wiki home page
  
    test "An admin creates home wikipage and another wikipage and reviews the all pages list" do
      login_as_admin
      visit_empty_home_wikipage
      create_home_wikipage
      view_home_wikipage
      create_another_wikipage
      view_another_wikipage
      review_wikipages_list
    end
  
    def visit_empty_home_wikipage
      visit "/"
      renders_template "wiki/new"
    end
  
    def create_home_wikipage
      fill_in 'body', :with => 'the wiki home page links to [[another wikipage]].'
      click_button 'Save'
    end
      
    def view_home_wikipage
      renders_template "wiki/show"
      response.body.should have_tag('.entry', /the wiki home page/)
    end
    
    def create_another_wikipage
      click_link 'another wikipage'
      renders_template "wiki/new"
      fill_in 'body', :with => 'another wiki page body'
      click_button 'Save'
    end
    
    def view_another_wikipage
      renders_template "wiki/show"
      response.body.should have_tag('.entry', /another wiki page body/)
    end
    
    def review_wikipages_list
      click_link 'all pages'
      renders_template 'wiki/index'
      has_tag '#wikipages tbody tr', :count => @section.wikipages.count
    end
  end
end