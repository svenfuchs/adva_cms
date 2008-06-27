require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::CategoriesController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :category, :article
    set_resource_paths :category, '/admin/sites/1/sections/1/'
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "categories", :index
      route.it_maps :get, "categories/1", :show, :id => '1'
      route.it_maps :get, "categories/new", :new
      route.it_maps :post, "categories", :create
      route.it_maps :get, "categories/1/edit", :edit, :id => '1'
      route.it_maps :put, "categories/1", :update, :id => '1'
      route.it_maps :delete, "categories/1", :destroy, :id => '1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    it_guards_permissions :show, :category
    it_assigns :categories
    it_renders_template :index
  end
  
  describe "GET to :new" do
    act! { request_to :get, @new_member_path }    
    it_guards_permissions :create, :category
    it_assigns :category
    it_renders_template :new
    
    it "instantiates a new category from section.categories" do
      @section.categories.should_receive(:build).any_number_of_times.and_return @category
      act!
    end    
  end
  
  describe "POST to :create" do
    act! { request_to :post, @collection_path }    
    it_guards_permissions :create, :category
    it_assigns :category
    
    it "instantiates a new category from section.categories" do
      @section.categories.should_receive(:build).any_number_of_times.and_return @category
      act!
    end
    
    describe "given valid category params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid category params" do
      before :each do @category.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
   
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }    
    it_guards_permissions :update, :category
    it_assigns :category
    it_renders_template :edit
    
    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end
  end 
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path }    
    it_guards_permissions :update, :category
    it_assigns :category    
    
    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end  
    
    it "updates the category with the category params" do
      @category.should_receive(:update_attributes).any_number_of_times.and_return true
      act!
    end
    
    describe "given valid category params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid category params" do
      before :each do @category.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_guards_permissions :destroy, :category
    it_assigns :category
    
    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end 
    
    it "should try to destroy the category" do
      @category.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @category.stub!(:destroy).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end