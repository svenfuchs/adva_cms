require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class Admin::EventsControllerTest < ActionController::TestCase
  tests Admin::EventsController
  with_common :is_superuser, :fixed_time, :calendar_with_events

  def default_params
    { :site_id => @section.site_id, :section_id => @section.id }
  end

  describe "routing" do
    calendar = Calendar.find_by_permalink('calendar-with-events')
    with_options :path_prefix => "/admin/sites/#{calendar.site_id}/sections/#{calendar.id}/", :site_id => calendar.site_id.to_s, :section_id => calendar.id.to_s do |route|
      route.it_maps :get, "events", :action => 'index'
      
      route.it_maps :get, "events/1", :action => 'show', :id => '1'
      route.it_maps :get, "events/new", :action => 'new'
      route.it_maps :post, "events", :action => 'create'
      route.it_maps :get, "events/1/edit", :action => 'edit', :id => '1'
      route.it_maps :put, "events/1", :action => 'update', :id => '1'
      route.it_maps :delete, "events/1", :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    it_renders_template :index
    it_assigns :events => :not_nil
    it_guards_permissions :show, :calendar_event
  end

  describe "GET to :new" do
    action { get :new, default_params }
    it_assigns :event => :not_nil
    it_renders_template :new
    it_guards_permissions :create, :calendar_event
  end

#  describe "GET to :edit" do
#    action { get :edit, default_params }
#    it_assigns :event
#    it_renders_template :edit
#    it_guards_permissions :update, :calendar_event
#  
#    it "fetches a event from section.events" do
#      @section.events.should_receive(:find).and_return @event
#      act!
#    end
#  end
#  
#  describe "POST to :create" do    
#    action { post , default_params.merge(:calendar_event => {:title => 'concert'}) }
#    it_guards_permissions :create, :calendar_event
#    it_assigns :event
#
#    it "instantiates a new event from section.events" do
#      @calendar.events.should_receive(:new).and_return @event
#      @event.should_receive(:save).and_return true
#      act!
#    end
#
#    describe "given valid event params" do
#      it_redirects_to { :edit, default_params.merge(:id => @event.id) }
#      it_assigns_flash_cookie :notice => :not_nil
#    end
#
#    describe "given invalid event params" do
#      before :each do 
#        @event.should_receive(:save).and_return false
#      end
#      it_renders_template :new
#      it_assigns_flash_cookie :error => :not_nil
#      it_does_not_trigger_any_event
#    end
#  end
#  
#  describe "PUT to :update" do    
#    action { post :update, default_params.merge(:calendar_event => {:title => 'concert'}) }
#    it_assigns :event
#    it_guards_permissions :update, :calendar_event
#
#    it "updates the event with the event params" do
#      @event.should_receive(:save).and_return true
#      act!
#    end
#  
#    describe "given valid event params" do
#      it_redirects_to { :edit }
#      it_assigns_flash_cookie :notice => :not_nil
#    end
#  
#    describe "given invalid event params" do
#      it_renders_template :edit
#      it_assigns_flash_cookie :error => :not_nil
#      it_does_not_trigger_any_event
#    end
#  end
#  
#  describe "DELETE to :destroy" do
#    action { post :delete, default_params.merge(:id => @event.id) }
#    it_assigns :event => lambda { @event }
#    it_guards_permissions :destroy, :calendar_event
#
#    it "should try to destroy the event" do
#      @event.should_receive :destroy
#    end
#  
#    describe "when destroy succeeds" do
#      it_redirects_to { @collection_path }
#      it_assigns_flash_cookie :notice => :not_nil
#    end
#  
#    describe "when destroy fails" do
#      it_renders_template :show
#      it_assigns_flash_cookie :error => :not_nil
#    end
#  end
end