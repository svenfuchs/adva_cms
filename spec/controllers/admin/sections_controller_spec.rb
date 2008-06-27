require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SectionsController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article
    set_resource_paths :section, '/admin/sites/1/'
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => '1' do |route|
      route.it_maps :get, "sections/1", :show, :id => '1'
      route.it_maps :get, "sections/new", :new
      route.it_maps :post, "sections", :create
      route.it_maps :put, "sections/1", :update, :id => '1'
      route.it_maps :delete, "sections/1", :destroy, :id => '1'
      # route.it_maps :get, "sections", :index
      # route.it_maps :get, "sections/1/edit", :edit, :id => '1'
    end
  end
  
  # describe "GET to :index" do
  #   act! { request_to :get, @collection_path }    
  #   it_assigns :sections
  #   it_renders_template :index
  #   # it_guards_permissions :index, :section
  # end
   
  describe "GET to :show" do
    act! { request_to :get, @member_path }    
    it_assigns :section
    it_renders_template :show    
    it_guards_permissions :show, :section
    
    it "fetches a section from site.sections" do
      @site.sections.should_receive(:find).and_return @section
      act!
    end
  end 
  
  describe "GET to :new" do
    act! { request_to :get, @new_member_path }    
    it_assigns :section
    it_renders_template :new
    it_guards_permissions :create, :section
    
    it "instantiates a new section from site.sections" do
      @site.sections.should_receive(:build).and_return @section
      act!
    end    
  end
  
  describe "POST to :create" do
    act! { request_to :post, @collection_path }    
    it_assigns :section
    it_guards_permissions :create, :section
    
    it "instantiates a new section from site.sections" do
      @site.sections.should_receive(:build).and_return @section
      act!
    end
    
    describe "given valid section params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid section params" do
      before :each do @section.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
   
  # describe "GET to :edit" do
  #   act! { request_to :get, @edit_member_path }    
  #   it_assigns :section
  #   it_renders_template :edit
  #   
  #   it "fetches a section from site.sections" do
  #     @site.sections.should_receive(:find).and_return @section
  #     act!
  #   end
  # end 
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path }    
    it_assigns :section    
    it_guards_permissions :update, :section
    
    it "fetches a section from site.sections" do
      @site.sections.should_receive(:find).and_return @section
      act!
    end  
    
    it "updates the section with the section params" do
      @section.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid section params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid section params" do
      before :each do @section.stub!(:update_attributes).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "PUT to :update_all" do
    before :each do
      @site.sections.stub! :update
      @site.sections.stub! :update_paths!
    end
    
    act! { request_to :put, @collection_path, :sections => {:foo => :bar} }    
    it_guards_permissions :update, :section
    
    it "updates the site's sections with the section params" do
      @site.sections.should_receive(:update).with(['foo'], [:bar])
      act!
    end
    
    it "updates the section's paths" do
      @site.sections.should_receive(:update_paths!)
      act!
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_assigns :section
    it_guards_permissions :destroy, :section
    
    it "fetches a section from site.sections" do
      @site.sections.should_receive(:find).and_return @section
      act!
    end 
    
    it "should try to destroy the section" do
      @section.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { @new_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @section.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end