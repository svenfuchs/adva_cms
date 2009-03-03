require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminPluginsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @admin_plugins_page = "http://#{@site.host}/admin/sites/#{@site.id}/plugins"
      @admin_plugin_page  = "http://#{@site.host}/admin/sites/#{@site.id}/plugins/test_plugin"
    end
  
    test "Admin reviews the plugins list and updates a plugin's settings" do
      login_as_admin
      visit @admin_plugins_page

      view_plugins_list
      revise_plugin_settings
    end

    def view_plugins_list
      @response.body.should have_tag('#plugins.list')
    end

    def revise_plugin_settings
      click_link 'test_plugin'
      fill_in 'string', 'a string'
      fill_in 'text', 'a text'
      click_button 'Save'
      request.url.should == @admin_plugin_page
    end
  end
end