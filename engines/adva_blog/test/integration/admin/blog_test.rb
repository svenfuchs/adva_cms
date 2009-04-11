require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminBlogTest < ActionController::IntegrationTest
    def setup
      super
      @section = Blog.first
      @site = @section.site
      use_site! @site
    end
  
    test "Admin creates a blog, changes settings and deletes it" do
      login_as_admin
      visit "/admin/sites/#{@site.id}"
      create_a_new_section
      revise_the_section_settings
      delete_the_section
    end

    def create_a_new_section
      click_link 'Sections'
      fill_in 'title', :with => 'the blog'
      choose 'Blog'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
    end

    def revise_the_section_settings
      click_link_within '#sidebar', 'Settings'
      fill_in 'title', :with => 'the uberblog'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/edit)
    end

    def delete_the_section
      click_link 'Delete'
      request.url.should =~ %r(/admin/sites/\d+/sections/new)
    end
  end
end