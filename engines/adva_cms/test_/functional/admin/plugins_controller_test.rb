require File.dirname(__FILE__) + "/../../test_helper"
  
# With.aspects << :access_control

class AdminPluginsControllerTest < ActionController::TestCase
  tests Admin::PluginsController

  def setup
    super
    login_as_superuser!
  end
  
  def default_params
    { :site_id => @site.id }
  end

  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
   
  describe "routing" do
    with_options :controller => 'admin/plugins', :site_id => "1" do |r|
      r.it_maps :get,    "/admin/sites/1/plugins",             :action => 'index'
      r.it_maps :get,    "/admin/sites/1/plugins/test_plugin", :action => 'show',    :id => 'test_plugin'
      r.it_maps :put,    "/admin/sites/1/plugins/test_plugin", :action => 'update',  :id => 'test_plugin'
      r.it_maps :delete, "/admin/sites/1/plugins/test_plugin", :action => 'destroy', :id => 'test_plugin'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    
    with :an_empty_site do
      it_guards_permissions :manage, :site
      
      with :access_granted do
        it_assigns :plugins
        it_renders_template :index
      end
    end
  end

  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @plugin.id) }
    
    with :a_plugin do
      it_guards_permissions :manage, :site
      
      with :access_granted do
        it_assigns :plugin
        it_renders_template :show
      end
    end
  end

  describe "PUT to :update" do
    action { put :update, default_params.merge(@params) }
    
    with :a_plugin do
      before { @params = { :id => @plugin.id, :string => 'changed' } }
      
      it_guards_permissions :manage, :site
    
      with :access_granted do
        it_assigns :plugin
        it_redirects_to { @member_path }
        it_assigns_flash_cookie :notice => :not_nil

        it "updates the plugin's config options" do
          @plugin.send(:config).reload.options[:string].should =~ /changed/
        end
      end
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @plugin.id)}

    with :a_plugin do
      it_guards_permissions :manage, :site
      
      with :access_granted do
        it_assigns :plugin
        it_redirects_to { @member_path }
        it_assigns_flash_cookie :notice => :not_nil

        it "resets the plugin's config options" do
          @plugin.send(:config).reload.options.should == {}
        end
      end
    end
  end
end
