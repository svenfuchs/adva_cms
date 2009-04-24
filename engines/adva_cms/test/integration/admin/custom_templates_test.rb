require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )
# TODO continue
module IntegrationTests
  class AdminCustomTemplatesTest < ActionController::IntegrationTest
    def setup
      super
      @section = Page.find_by_title 'a page'
      @site = @section.site
      use_site! @site
    end

    test "Admin adds custom template settings and checks the frontend" do
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
      select 'Page'
      click_button 'commit'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
    end

    def revise_the_page_settings
      click_link_within '#main_menu', 'Settings'
      fill_in 'title', :with => 'the uberpage'
      select 'Never expire', :from => 'Comments'
      click_button 'commit'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/edit)
    end

    def delete_the_page
      click_link "delete_section_#{assigns(:section).id}"
      request.url.should =~ %r(/admin/sites/\d+/sections/new)
    end
  end
end