require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

module IntegrationTests
  class AdminThemeFilesTest < ThemeIntegrationTest
    include ThemeTestHelper
    
    def setup
      super
      @site = use_site! 'site with pages'
      @theme = @site.themes.find_by_theme_id('a-theme')
      @theme.activate!
      @admin_theme_files_page = "/admin/sites/#{@site.id}/themes/#{@theme.id}/files"
    end
    
    # FIXME implement or delete if already implemented
    #
    # test "Admin creates a bunch of theme files, updates and deletes them" do
    #   login_as_superuser
    #   visit_theme_show_page
    #   # check_homepage '<body>'
    #   
    #   # template
    #   create_a_new_theme_file :filename => 'layouts/default.html.erb', :data => 'the default layout: <%= yield %>'
    #   create_a_new_theme_file :filename => 'pages/articles/index.html.erb', :data => 'the page index theme'
    #   check_homepage 'the default layout: the page index theme'
    #   
    #   # javascript
    #   create_a_new_theme_file :filename => 'effects.js', :data => 'alert("booom!")'
    #   update_the_theme_file   :data => 'alert("booom boom boom!")'
    # 
    #   # stylesheet
    #   create_a_new_theme_file :filename => 'styles.css', :data => 'body { background-color: red }'
    #   update_the_theme_file   :data => 'body { background-color: yellow }'
    # 
    #   # image
    #   create_a_new_theme_file :filename => 'the-logo.png', :data => image_fixture
    #   update_the_theme_file   :filename => 'the-ueber-logo.png'
    #   
    #   # update the layout
    #   click_link 'layouts/default.html.erb'
    # 
    #   update_the_theme_file   :data => <<-eoc
    #     <%= theme_javascript_include_tag 'a-theme', :all, :cache => true %>
    #     <%= theme_stylesheet_link_tag 'a-theme', 'styles' %>
    #     <%= theme_image_tag 'a-theme', 'the-ueber-logo' %>
    #     the updated theme default layout
    #   eoc
    # 
    #   check_homepage '<script src="/themes/a-theme/javascripts/all.js" type="text/javascript"></script>',
    #                  '<link href="/themes/a-theme/stylesheets/styles.css" media="screen" rel="stylesheet" type="text/css" />',
    #                  '<img alt="The-ueber-logo" src="/themes/a-theme/images/the-ueber-logo" />',
    #                  'the updated theme default layout'
    # 
    #   delete_the_theme_file 'layouts/default.html.erb'
    #   delete_the_theme_file 'effects.js'
    #   delete_the_theme_file 'styles.css'
    #   delete_the_theme_file 'the-ueber-logo.png'
    # end

    test "Admin uploads a new theme file" do
      login_as_superuser
      visit_theme_show_page
      # TODO: re-enable when webrat bug is fixed
      # upload_theme_file
    end
    
    test "cancel link redirects to theme_file index view" do
      login_as_superuser
      visit_theme_file_edit_page
      click_link 'cancel'
      assert_template 'admin/theme_files/index'
    end
    
    def check_homepage(*strings)
      @backbutton = request.path
      visit '/'
      strings.each { |str| has_text str }
      visit @backbutton
    end

    def visit_theme_show_page
      visit @admin_theme_files_page
      assert_template "admin/theme_files/index"
    end
    
    def visit_theme_file_edit_page
      visit @admin_theme_files_page + "/#{@theme.files.first.id}"
      assert_template "admin/theme_files/show"
    end
    
    def create_a_new_theme_file(attributes)
      click_link 'New'
      assert_template "admin/theme_files/new"

      attributes.each do |name, value|
        fill_in name, :with => value
      end
      click_button 'Save'
      assert_template "admin/theme_files/show"
    end
    
    def upload_theme_file
      click_link 'Upload'
      assert_template "admin/theme_files/import"
      
      attach_file 'files[][data]', image_fixture.path # ActionController::TestUploadedFile.new()
      click_button 'Upload'

      assert_template "admin/theme_files/show"
    end

    def update_the_theme_file(attributes)
      attributes.each do |name, value|
        fill_in name, :with => value
      end
      click_button 'Save'
      assert_template "admin/theme_files/show"
    end
    
    def delete_the_theme_file(name)
      click_link name
      click_link 'Delete'
      assert_template "admin/themes/show"
    end
  end
end