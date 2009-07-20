require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminSectionTest < ActionController::IntegrationTest
    def setup
      super
      @section = Page.find_by_title 'a page'
      @site = @section.site
      use_site! @site
    end
  
    test "Admin creates a page, changes settings and deletes it" do
      login_as_admin
      visit "/admin/sites/#{@site.id}"
      create_a_new_page
      revise_the_page_settings
      delete_the_page
    end
    
    test "Admin creates a page, edits the article and deletes the section, after this the admin
          visits the overview page (fix for bug #222)" do
      login_as_admin
      visit "/admin/sites/#{@site.id}"
      create_a_new_page
      post_the_article_form
      click_link_within '#main_menu', 'Settings'
      delete_the_page
      visit_overview_page
    end
    
    test "Admin creates a page and sets it as a child section of the home section" do
      login_as_admin
      visit "/admin/sites/#{@site.id}/sections"
      create_a_new_child_page
    end
    
    def create_a_new_page
      click_link 'Sections'
      click_link 'New'
      fill_in 'title', :with => 'the page'
      select 'Page'
      click_button 'Save'
      
      assert @site.sections.last.is_a?(Page)
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
    end
    
    def create_a_new_child_page
      click_link 'New'
      fill_in 'title', :with => 'the child blog'
      select 'Blog', :from => 'section_type'
      select @section.title, :from => 'section_parent_id'
      click_button 'Save'
      
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
      section = @site.sections.find_by_title('the child blog')
      assert section
      assert section.is_a?(Blog)
      assert section.parent == @section
    end
    
    def post_the_article_form
      assert_template 'admin/articles/new'
      
      fill_in     'article[body]',  :with => 'the article body'
      check       'article[draft]'
      click_button :save
    end

    def revise_the_page_settings
      click_link_within '#main_menu', 'Settings'
      fill_in 'title', :with => 'the uberpage'
      select 'Never expire', :from => 'Comments'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/edit)
    end

    def delete_the_page
      click_link 'Delete'
      request.url.should =~ %r(/admin/sites/\d+/sections/new)
    end
    
    def visit_overview_page
      click_link 'Overview'
      assert_template 'admin/sites/show'
    end
  end
end