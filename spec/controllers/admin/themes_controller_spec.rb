require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ThemesController do
  include SpecControllerHelper
  
  before :each do
    scenario :empty_site, :theme_with_files

    @site.stub!(:theme_names_will_change!)
    
    @params = {:theme => {:name => 'a theme', :author => 'Sven Fuchs', :version => '0.1', :summary => 'experimental'}}

    set_resource_paths :theme, '/admin/sites/1/'
    @selected_themes_path = "#{@collection_path}/selected"
    @selected_theme_path = "#{@collection_path}/selected/theme-1"
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |route|
      route.it_maps :get, "themes", :index
      route.it_maps :get, "themes/theme-1", :show, :id => 'theme-1'
      route.it_maps :get, "themes/new", :new
      route.it_maps :post, "themes", :create
      # route.it_maps :get, "themes/theme-1/edit", :edit, :id => 'theme-1' # unused
      route.it_maps :put, "themes/theme-1", :update, :id => 'theme-1'
      route.it_maps :delete, "themes/theme-1", :destroy, :id => 'theme-1'
      route.it_maps :post, "themes/selected", :select
      route.it_maps :delete, "themes/selected/theme-1", :unselect, :id => 'theme-1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    # it_guards_permissions :show, :theme # deactivated all :show permissions in the backend
    it_assigns :themes
    it_renders_template :index
  end
  
  describe "GET to :show" do    
    act! { request_to :get, @member_path }
    # it_guards_permissions :show, :theme # deactivated all :show permissions in the backend
    it_assigns :theme
  end  
  
  describe "POST to :create" do
    act! { request_to :post, @collection_path, @params }    
    it_guards_permissions :create, :theme
    it_assigns :theme
    
    it "instantiates a new theme from site.themes" do
      @site.themes.should_receive(:build).and_return @theme
      act!
    end
    
    it "tries to save the theme" do
      @theme.should_receive(:save).and_return true
      act!
    end
    
    describe "given valid theme params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid theme params" do
      before :each do @theme.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path, @params }    
    it_guards_permissions :update, :theme
    it_assigns :theme    
    
    it "fetches an theme from site.themes" do
      @site.themes.should_receive(:find).and_return @theme
      act!
    end  
    
    it "updates the theme with the theme params" do
      @theme.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid theme params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid theme params" do
      before :each do @theme.stub!(:update_attributes).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_guards_permissions :destroy, :theme
    it_assigns :theme
    
    it "fetches an theme from site.themes" do
      @site.themes.should_receive(:find).and_return @theme
      act!
    end 
    
    it "should try to destroy the theme" do
      @theme.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    
      it "expires page cache for the current site" do
        controller.should_receive(:expire_site_page_cache)
        act!
      end
    end
    
    describe "when destroy fails" do
      before :each do @theme.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end  
  
  describe "POST to :select" do
    act! { request_to :post, @selected_themes_path, :id => @theme.id }
    it_guards_permissions :update, :theme
    it_redirects_to { @collection_path }
    
    it "adds the theme id to the site's theme_names" do
      @site.theme_names.should_receive(:<<).with @theme.id
      act!
    end
    
    it "saves the site" do
      @site.should_receive(:save).and_return true
      act!
    end
    
    it "expires page cache for the current site" do
      controller.should_receive(:expire_site_page_cache)
      act!
    end
  end
  
  describe "DELETE to :unselect" do
    act! { request_to :delete, @selected_theme_path }
    it_guards_permissions :update, :theme
    it_redirects_to { @collection_path }
    
    it "removes the theme id from the site's theme_names" do
      @site.theme_names.should_receive(:delete).with @theme.id
      act!
    end
    
    it "saves the site" do
      @site.should_receive(:save).and_return true
      act!
    end
    
    it "expires page cache for the current site" do
      controller.should_receive(:expire_site_page_cache)
      act!
    end
  end
end
