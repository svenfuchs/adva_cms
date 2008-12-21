require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminCachedPagesControllerTest < ActionController::TestCase
  tests Admin::CachedPagesController
  
  with_common :a_section, :a_cached_page, :is_superuser

  def default_params
    { :site_id => @site.id }
  end
  
  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "cached_pages",   :action => 'index'
      r.it_maps :delete, "cached_pages",   :action => 'clear'
      r.it_maps :delete, "cached_pages/1", :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    it_guards_permissions :manage, :cached_page

    with :access_granted do
      it_assigns :cached_pages
      it_renders_template :index
    end
  end
  
  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @cached_page.id) }
    
    it_guards_permissions :manage, :cached_page
    
    with :access_granted do
      it_assigns :cached_page
      it_destroys :cached_page
      it_renders :template, :destroy, :format => :js
    end
  end
  
  describe "DELETE to :clear" do
    action { delete :clear, default_params }

    it_guards_permissions :manage, :cached_page
    
    with :access_granted do
      it_redirects_to { admin_cached_pages_path }
      it_destroys :cached_page

      expect "expires the site's page cache" do
        mock.proxy(@controller).expire_site_page_cache
      end
    end
  end
end
