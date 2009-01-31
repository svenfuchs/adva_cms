require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminSitesTest < ActionController::IntegrationTest
    def setup
      super
      use_site! 'site with sections'
      @old_multi_site_enabled, Site.multi_sites_enabled = Site.multi_sites_enabled, true
    end
    
    def teardown
      super
      Site.multi_sites_enabled = @old_multi_site_enabled
    end
  
    test "Admin creates a new site, changes the settings and deletes it (in multi-site mode)" do
      login_as_superuser
      visit "/admin/sites/"
      create_a_new_site
      revise_the_site_settings
      delete_the_site
    end

    def create_a_new_site
      click_link 'New' # FIXME move link to the sidebar
      fill_in 'site[title]', :with => 'the site'
      fill_in 'site[name]',  :with => 'the site'
      fill_in 'site[host]',  :with => 'http://the-site.com'
      fill_in 'section[title]', :with => 'the home section'
      choose 'Section'
      click_button 'Create'
      request.url.should =~ %r(/admin/sites/\d+)
    end

    def revise_the_site_settings
      click_link 'Settings'
      fill_in 'site[title]', :with => 'the ubersite'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+)
    end

    def delete_the_site
      click_link 'Delete this site'
      request.url.should =~ %r(/admin/sites)
    end
  end
end