require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminSitesTest < ActionController::IntegrationTest
    def setup
      super
      use_site! 'site with pages'
      @old_multi_site_enabled, Site.multi_sites_enabled = Site.multi_sites_enabled, true
    end
    
    def teardown
      super
      Site.multi_sites_enabled = @old_multi_site_enabled
    end
  
    test "Admin creates a new site, changes the settings and deletes it (in multi-site mode)" do
      login_as_superuser
      visit "/admin/sites"
      assert_template 'admin/sites/index'
      
      create_a_new_site
      revise_the_site_settings
      delete_the_site
    end

    def create_a_new_site
      click_link 'New' # FIXME move link to the sidebar
      fill_in 'site[title]', :with => 'the new site'
      fill_in 'site[name]',  :with => 'the new site'
      fill_in 'site[host]',  :with => 'http://the-new-site.com'
      fill_in 'section[title]', :with => "the new site's home page"
      click_button 'Save'
      assert_template "admin/sites/show"
    end

    def revise_the_site_settings
      click_link 'Settings'
      fill_in 'site[title]', :with => 'the ubersite'
      click_button 'Save'
      assert_template "admin/sites/edit"
    end

    def delete_the_site
      click_link 'Delete'
      assert_template "admin/sites/index"
    end
  end
end