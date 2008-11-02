require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::WikipagesController do
  include SpecControllerHelper

  before :each do
    stub_scenario :wiki_with_wikipages
    set_resource_paths :wikipage, '/admin/sites/1/sections/1/'

    controller.stub! :require_authentication
    controller.stub!(:has_permission?).and_return true
    controller.stub!(:params_author)
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "wikipages", :index
      route.it_maps :get, "wikipages/1", :show, :id => '1'
      route.it_maps :get, "wikipages/new", :new
      route.it_maps :post, "wikipages", :create
      route.it_maps :get, "wikipages/1/edit", :edit, :id => '1'
      route.it_maps :put, "wikipages/1", :update, :id => '1'
      route.it_maps :delete, "wikipages/1", :destroy, :id => '1'
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    # it_guards_permissions :show, :wikipage # deactivated all :show permissions in the backend
    it_assigns :wikipages
    it_renders_template :index
  end

  describe "GET to :new" do
    act! { request_to :get, @new_member_path }
    it_assigns :wikipage
    it_renders_template :new
    it_guards_permissions :create, :wikipage
  
    it "instantiates a new wikipage from section.wikipages" do
      @section.wikipages.should_receive(:build).and_return @wikipage
      act!
    end
  end
  
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    it_assigns :wikipage
    it_renders_template :edit
    it_guards_permissions :update, :wikipage
  
    it "fetches a wikipage from section.wikipages" do
      @section.wikipages.should_receive(:find).and_return @wikipage
      act!
    end
  end
  
  describe "POST to :create" do
    before :each do
      @wikipage.stub!(:state_changes).and_return([:created])
    end
    
    act! { request_to :post, @collection_path }
    it_guards_permissions :create, :wikipage
    it_assigns :wikipage

    it "instantiates a new wikipage from section.wikipages" do
      @wiki.wikipages.should_receive(:create).and_return @wikipage
      act!
    end

    describe "given valid wikipage params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :wikipage_created
    end

    describe "given invalid wikipage params" do
      before :each do 
        @wiki.wikipages.should_receive(:create).and_return false 
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "PUT to :update with no :version param" do
    before :each do
      @wikipage.stub!(:state_changes).and_return([:updated])
    end
    
    act! { request_to :put, @member_path }
    it_assigns :wikipage
    it_guards_permissions :update, :wikipage
  
    it "updates the wikipage with the wikipage params" do
      @wikipage.should_receive(:update_attributes).and_return true
      act!
    end
  
    describe "given valid wikipage params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :wikipage_updated
    end
  
    describe "given invalid wikipage params" do
      before :each do
        @wikipage.stub!(:update_attributes).and_return false
      end
      
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "PUT to :update", "with a :version param" do
    before :each do
      @wikipage.stub!(:revert_to!).and_return true
      @wikipage.stub!(:state_changes).and_return([:rolledback])
    end

    act! { request_to :put, @member_path, {:version => 1} }
    it_guards_permissions :update, :wikipage
    it_assigns :wikipage

    it "tries to roll the wikipage back to the given version" do
      @wikipage.should_receive(:revert_to!).and_return true
      act!
    end

    describe "given the wikipage can be rolled back the given version" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :wikipage_rolledback
    end

    describe "given the wikipage can not be rolled back the given version" do
      before :each do
        @wikipage.stub!(:revert_to!).and_return false
      end
      
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "DELETE to :destroy" do
    before :each do
      @wikipage.stub!(:state_changes).and_return([:deleted])
    end
    
    act! { request_to :delete, @member_path }
    it_assigns :wikipage
    it_guards_permissions :destroy, :wikipage
  
    it "fetches a wikipage from section.wikipages" do
      @section.wikipages.should_receive(:find).and_return @wikipage
      act!
    end
  
    it "should try to destroy the wikipage" do
      @wikipage.should_receive :destroy
      act!
    end
  
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :wikipage_deleted
    end
  
    describe "when destroy fails" do
      before :each do
        @wikipage.stub!(:destroy).and_return false
      end
      
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end