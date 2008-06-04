require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::CachedPagesController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article, :cached_page
    set_resource_paths :cached_page, '/admin/sites/1/'
    @controller.stub! :require_authentication
    @controller.stub! :guard_permission
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |route|
      route.it_maps :get, "cached_pages", :index
      route.it_maps :delete, "cached_pages", :clear
      route.it_maps :delete, "cached_pages/1", :destroy, :id => '1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    it_assigns :cached_pages
    it_renders_template :index
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_assigns :cached_page
    it_renders :template, :destroy, :format => :js
    
    it "fetches a cached_page from site.cached_pages" do
      @site.cached_pages.should_receive(:find).and_return @cached_page
      act!
    end 
    
    it "should try to destroy the cached_page" do
      @cached_page.should_receive :destroy
      act!
    end 
  end
  
  describe "DELETE to :clear" do
    act! { request_to :delete, @collection_path }    
    it_redirects_to { @collection_path }
    
    before :each do
      controller.class.stub!(:expire_page)
    end
    
    it "iterates the site's cached pages and tells the controller to expire them with their url" do
      controller.class.should_receive(:expire_page).any_number_of_times.with @cached_page.url
      act!
    end 
    
    it "should deletes the site's cached pages" do
      @site.cached_pages.should_receive(:delete_all)
      act!
    end 
  end
end