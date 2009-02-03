require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

# FIXME add steps: select/unselect theme

module IntegrationTests
  class AdminThemesTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'
      @site.themes.destroy_all
      @admin_themes_index_page = "/admin/sites/#{@site.id}/themes"
    end

    test "Admin creates a new theme, updates its attributes and deletes it" do
      login_as_superuser
      visits_themes_index_page
      creates_a_new_theme
      updates_the_themes_attributes
      deletes_the_theme
    end

    def visits_themes_index_page
      visit @admin_themes_index_page
      assert_template "admin/themes/index"
    end

    def creates_a_new_theme
      click_link 'New theme'
      assert_template "admin/themes/new"

      fill_in 'name', :with => 'a new theme'
      click_button 'Save'
      assert_template "admin/themes/index"
    end

    def updates_the_themes_attributes
      click_link 'Edit'
      assert_template "admin/themes/show"
      
      click_link 'Edit theme' # FIXME ugh ...
      assert_template "admin/themes/edit"

      fill_in 'name', :with => 'an updated theme'
      click_button 'Save'
      assert_template "admin/themes/show"
    end
    
    def deletes_the_theme
      click_link 'Delete theme'
      assert_template "admin/themes/index"
    end
  end
end