require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

# FIXME add steps: select/unselect theme

module IntegrationTests
  class AdminThemeCacheTest < ThemeIntegrationTest
    include ThemeTestHelper
  
    def setup
      super
      @site = use_site! 'site with pages'
      @theme = @site.themes.first
    end
    
    test "Theme assets are cleared when admin clears the site cache" do
      login_as_superuser
      setup_theme_with_cached_files(@theme)
      visit_page_cache_page
      click_link 'Clear all'
      theme_cache_is_cleared
    end
    
    def visit_page_cache_page
      visit admin_cached_pages_path(@site)
      assert_template 'admin/cached_pages/index'
    end
    
    def theme_cache_is_cleared
      theme_files = Dir.glob("#{@theme.path}/**/*")
      theme_files.should_not include("#{@theme.path}/javascripts/cached_javascript.js")
      theme_files.should_not include("#{@theme.path}/stylesheets/cached_stylesheet.css")
      theme_files.should_not include("#{@theme.path}/javascripts/folder/cached/")
    end
    
    def setup_theme_with_cached_files(theme = theme)
      uploaded_template(theme)
      uploaded_stylesheet(theme)
      uploaded_javascript(theme)
      uploaded_image(theme)
      FileUtils.touch(theme.path + '/stylesheets/cached_stylesheet.css')
      FileUtils.touch(theme.path + '/javascripts/cached_javascript.js')
      FileUtils.mkdir_p(theme.path + '/javascripts/folder/cached/folder')
      FileUtils.touch(theme.path + '/javascripts/folder/cached/folder/some_javascript.css')
    end
  end
  
  class AdminThemesTest < ThemeIntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @site.themes.destroy_all
      # @admin_themes_index_page = "/admin/sites/#{@site.id}/themes"
    end

    # test "Admin creates a new theme, updates its attributes and deletes it" do
    #   login_as_superuser
    #   visit_themes_index_page
    #   create_a_new_theme
    #   update_the_themes_attributes
    #   delete_the_theme
    # end
    
    test "Admin creates a new theme with some files, exports the theme and reimports it" do
    #   login_as_superuser
    #   visit_themes_index_page
    #   create_a_new_theme
    # 
    #   click_link 'Edit'
    #   click_link 'Files'
    #   creates_a_new_theme_file :filename => 'layouts/default.html.erb', :data => 'the theme default layout'
    #   creates_a_new_theme_file :filename => 'effects.js', :data => 'alert("booom!")'
    # 
    #   click_link 'Themes'
    #   click_link 'Edit'
    #   export_theme
    #   reimport_theme
    end

    def visit_themes_index_page
      visit @admin_themes_index_page
      assert_template "admin/themes/index"
    end

    def create_a_new_theme
      click_link 'Create one now'
      assert_template "admin/themes/new"

      fill_in 'name', :with => 'a new theme'
      click_button 'Save'
      assert_template "admin/themes/index"
    end
    
    def creates_a_new_theme_file(attributes)
      click_link 'New'
      assert_template "admin/theme_files/new"

      attributes.each do |name, value|
        fill_in name, :with => value
      end
      click_button 'Save'
      assert_template "admin/theme_files/show"
    end

    def update_the_themes_attributes
      click_link 'Edit'
      assert_template "admin/themes/edit"

      fill_in 'name', :with => 'an updated theme'
      click_button 'Save'
      assert_template "admin/themes/show"
    end
    
    def delete_the_theme
      click_link 'Delete'
      assert_template "admin/themes/index"
    end
    
    def export_theme
      click_link 'Download'
      @exported_theme = "#{Rails.root}/tmp/sites/site-#{@site.id}/themes/imported-theme.zip"
      ::File.open(@exported_theme, 'w+') { |file| file.write(@response.body) }
    end
    
    def reimport_theme
      assert_difference 'Theme.count' do
        visit_themes_index_page
        click_link 'Import'
        attach_file 'Zip file', @exported_theme
        click_button 'Import'
        assert_template 'admin/themes/index'
        has_tag 'h4[title=?]', 'imported-theme', 'imported-theme'
      end
    end
  end
end