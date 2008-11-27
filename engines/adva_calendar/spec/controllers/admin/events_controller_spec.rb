require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::EventsController do
  include SpecControllerHelper
  
  before :each do
    @site = Site.find(1)
    @section = @site.sections.find(1).becomes(Calendar)
    @event = @section.events.find(1)
    set_resource_paths :event, '/admin/sites/1/sections/1/'

    controller.stub! :require_authentication
    controller.stub!(:has_permission?).and_return true
    controller.stub!(:params_author)
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "events", :index
      route.it_maps :get, "events/1", :show, :id => '1'
      route.it_maps :get, "events/new", :new
      route.it_maps :post, "events", :create
      route.it_maps :get, "events/1/edit", :edit, :id => '1'
      route.it_maps :put, "events/1", :update, :id => '1'
      route.it_maps :delete, "events/1", :destroy, :id => '1'
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    # it_guards_permissions :show, :event # deactivated all :show permissions in the backend
    it_assigns :events
    it_renders_template :index
  end

  describe "GET to :new" do
    act! { request_to :get, @new_member_path }
    it_assigns :event
    it_renders_template :new
    it_guards_permissions :create, :event

    it "instantiates a new event from section.events" do
      @section.events.should_receive(:new).and_return Calendar::Event.new(:title => 'New event')
      act!
    end
  end
  
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    it_assigns :event
    it_renders_template :edit
    it_guards_permissions :update, :event
  
    it "fetches a event from section.events" do
      @section.events.should_receive(:find).and_return Calendar::Event.find(1)
      act!
    end
  end
  
  describe "POST to :create" do
    
    act! { request_to :post, @collection_path }
    it_guards_permissions :create, :event
    it_assigns :event

    it "instantiates a new event from section.events" do
      @calendar.events.should_receive(:create).and_return @event
      act!
    end

    describe "given valid event params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :event_created
    end

    describe "given invalid event params" do
      before :each do 
        @calendar.events.should_receive(:create).and_return false 
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "PUT to :update" do
    before :each do
      @event.stub!(:state_changes).and_return([:updated])
    end
    
    act! { request_to :put, @member_path }
    it_assigns :event
    it_guards_permissions :update, :event
  
    it "updates the event with the event params" do
      @event.should_receive(:update_attributes).and_return true
      act!
    end
  
    describe "given valid event params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :event_updated
    end
  
    describe "given invalid event params" do
      before :each do
        @event.stub!(:update_attributes).and_return false
      end
      
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "DELETE to :destroy" do
    before :each do
      @event.stub!(:state_changes).and_return([:deleted])
    end
    
    act! { request_to :delete, @member_path }
    it_assigns :event
    it_guards_permissions :destroy, :event
  
    it "fetches a event from section.events" do
      @section.events.should_receive(:find).and_return @event
      act!
    end
  
    it "should try to destroy the event" do
      @event.should_receive :destroy
      act!
    end
  
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
      # it_triggers_event :event_deleted
    end
  
    describe "when destroy fails" do
      before :each do
        @event.stub!(:destroy).and_return false
      end
      
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end