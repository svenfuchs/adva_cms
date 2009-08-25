require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

module IntegrationTests
  class ThemeImportTest < ThemeIntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @site.themes.destroy_all
      @admin_themes_index_page = "/admin/sites/#{@site.id}/themes"
    end
    
    test "superuser imports a theme and confirms that file paths are correct [bug #308]" do
      login_as_superuser
      visit_themes_index_page
      click_link 'Import'
      import_theme
      visit_theme_files_index_page
      has_tag 'a', 'templates/foo/bar/template.html.erb'
      has_tag 'a', 'images/preview.png'
      has_tag 'a', 'images/rails.png'
      has_tag 'a', 'stylesheets/styles.css'
      has_tag 'a', 'javascripts/effects.js'
    end

    def visit_themes_index_page
      visit @admin_themes_index_page
      assert_template "admin/themes/index"
    end

    def visit_theme_files_index_page
      visit "/admin/sites/#{@site.id}/themes/#{Theme.last.id}/files"
      assert_template "admin/theme_files/index"
    end

    def import_theme
      assert_difference 'Theme.count' do
        attach_file 'Zip file', "#{Rails.root}/vendor/adva/engines/adva_themes/test/fixtures/theme-for-import.zip"
        click_button 'Import'
      end
    end
  end
end