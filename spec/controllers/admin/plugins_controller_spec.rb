require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::PluginsController do
  include SpecControllerHelper
  
  before :each do
    scenario :empty_site
    
    @plugin = Engines.plugins[:test_plugin]
    set_resource_paths :plugin, '/admin/sites/1/'
    
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |route|
      route.it_maps :get, "plugins", :index
      route.it_maps :get, "plugins/test_plugin", :show, :id => 'test_plugin'
      route.it_maps :get, "plugins/test_plugin/edit", :edit, :id => 'test_plugin'
      route.it_maps :put, "plugins/test_plugin", :update, :id => 'test_plugin'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    # it_guards_permissions :show, :plugin
    it_assigns :plugins
    it_renders_template :index
  end
  
  describe "GET to :show" do
    act! { request_to :get, @member_path }    
    # it_guards_permissions :show, :plugin
    it_assigns :plugin
    it_renders_template :show
  end
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path, :plugin => {'name' => 'value'} }
    it_assigns :plugin    
    it_redirects_to { @member_path }
    it_assigns_flash_cookie :notice => :not_nil
    
    it "updates the plugin's config options" do
      @plugin.should_receive(:options=).with 'name' => 'value'
      act!
    end
    
    it "saves the plugin" do
      @plugin.should_receive(:save!)
      act!
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_assigns :plugin
    it_redirects_to { @member_path }
    it_assigns_flash_cookie :notice => :not_nil
    
    it "resets the plugin's config options" do
      @plugin.should_receive(:options=).with({})
      act!
    end 
    
    it "saves the plugin" do
      @plugin.should_receive(:save!)
      act!
    end
  end
end