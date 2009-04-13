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

    def create_a_new_page
      click_link 'Sections'
      click_link 'New'
      fill_in 'title', :with => 'the page'
      choose 'Page'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
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
  end
end