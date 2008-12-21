require File.dirname(__FILE__) + "/../../test_helper"
  
# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

With.aspects << :access_control

class AdminSitesControllerTest < ActionController::TestCase
  tests Admin::SitesController

  def setup
    super
    login_as_superuser!
    
    # FIXME test in single_site_mode, too
    Site.multi_sites_enabled = true
  end
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
   
  describe "routing" do
    with_options :controller => 'admin/sites' do |r|
      r.it_maps :get,    "/admin/sites",        :action => 'index'
      r.it_maps :get,    "/admin/sites/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "/admin/sites/new",    :action => 'new'
      r.it_maps :post,   "/admin/sites",        :action => 'create'
      r.it_maps :get,    "/admin/sites/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "/admin/sites/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "/admin/sites/1",      :action => 'destroy', :id => '1'
    end
  end
  
  describe "GET to :index" do
    action { get :index }
    
    with :an_empty_site do
      # FIXME
      # hard to test because :admin and :moderator roles need a context and
      # BaseController#require_authentication tests for has_role?(:admin)
      # it_guards_permissions :show, :site
    
      with :access_granted do
        it_assigns :sites
        it_renders_template :index
      end
    end
  end
  
  describe "GET to :show" do
    action { get :show, :id => @site.id }
    
    with :an_empty_site do
      it_guards_permissions :show, :site
      
      with :access_granted do
        it_assigns :site
        it_renders_template :show
      end
    end
  end
  
  describe "GET to :new" do
    action { get :new }
    
    # FIXME
    # hard to test because :admin and :moderator roles need a context and
    # BaseController#require_authentication tests for has_role?(:admin)
    # it_guards_permissions :create, :site
    
    with :access_granted do
      it_assigns :site
      it_renders_template :new
    end
  end
  
  describe "POST to :create" do
    action { post :create, @params }
  
    with :valid_site_params do
      # FIXME
      # hard to test because :admin and :moderator roles need a context and
      # BaseController#require_authentication tests for has_role?(:admin)
      # it_guards_permissions :create, :site
  
      with :access_granted do
        it_assigns :site
        it_redirects_to { admin_site_path(assigns(:site)) }
        it_assigns_flash_cookie :notice => :not_nil
      end
    end
  
    with :invalid_site_params do
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "GET to :edit" do
    action { get :edit, :id => @site.id }
    
    with :an_empty_site do
      it_guards_permissions :update, :site
      
      with :access_granted do
        it_assigns :site
        it_renders_template :edit
      end
    end
  end
  
  describe "PUT to :update" do
    action { put :update, @params.merge(:id => @site.id) }
  
    with :an_empty_site do
      with :valid_site_params do 
        before { @params[:site][:name] = 'name changed' }
        
        it_guards_permissions :update, :site
        
        with :access_granted do
          it_assigns :site
          it_redirects_to { edit_admin_site_path(@site) }
          it_assigns_flash_cookie :notice => :not_nil
  
          it "updates the site with the site params" do
            @site.reload.name.should =~ /changed/
          end
        end
      end
      
      with :invalid_site_params do 
        it_renders_template :edit
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end
  
  describe "DELETE to :destroy" do
    action { delete :destroy, :id => @site.id }

    with :an_empty_site do
      it_guards_permissions :destroy, :site
      
      with :access_granted do
        it_assigns :site
        it_destroys :site
        it_redirects_to { admin_sites_path }
        it_assigns_flash_cookie :notice => :not_nil
      end
    end
  end
end

