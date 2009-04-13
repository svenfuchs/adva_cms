require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminCachedPagesTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @admin_cached_pages_page = "/admin/sites/#{@site.id}/cached_pages"
    end

    test "Admin clears the page cache, views a frontend page, checks the page cache and expires that page" do
      login_as_admin
      visit @admin_cached_pages_page

      clears_page_cache
      view_home_page
      check_page_cache
      expire_cached_home_page
    end

    def clears_page_cache
      click_link 'Clear all'
      @response.body.should have_tag('.empty')
    end

    def view_home_page
      visit '/'
      # FIXME have a matcher/macro for this
      assert File.exists?(ActionController::Base.send(:page_cache_path, request.path))
    end

    def check_page_cache
      visit @admin_cached_pages_page
      @response.body.should have_tag('#cached_pages tbody tr', :count => 1)
    end

    def expire_cached_home_page
      # FIXME this ajax request does not work with webrat
      # click_link 'Clear'
      # @response.body.should have_tag('.empty')
    end
  end
end