require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class Admin::EventsControllerTest < ActionController::TestCase
  tests Admin::EventsController
  with_common :is_superuser, :access_granted, :fixed_time, :calendar_with_events

  def default_params
    { :site_id => @section.site_id, :section_id => @section.id }
  end

  describe "routing" do
    calendar = Calendar.find_by_permalink('calendar-with-events')
    with_options :path_prefix => "/admin/sites/#{calendar.site_id}/sections/#{calendar.id}/", :site_id => calendar.site_id.to_s, :section_id => calendar.id.to_s do |route|
      route.it_maps :get,    "events",        :action => 'index'
      route.it_maps :get,    "events/1",      :action => 'show',    :id => '1'
      route.it_maps :get,    "events/new",    :action => 'new'
      route.it_maps :post,   "events",        :action => 'create'
      route.it_maps :get,    "events/1/edit", :action => 'edit',    :id => '1'
      route.it_maps :put,    "events/1",      :action => 'update',  :id => '1'
      route.it_maps :delete, "events/1",      :action => 'destroy', :id => '1'
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

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @section.events.first.id) }
    it_assigns :event => lambda {@section.events.first}
    it_renders_template :edit
    it_guards_permissions :update, :calendar_event
  end

  describe "POST to :create" do
    action { post :create, default_params.merge(@params || {}) }
    it_guards_permissions :create, :calendar_event
    it_assigns :event => :not_nil

    with :invalid_event_params do
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
    with :valid_event_params do
      it_saves :event
      it_assigns_flash_cookie :notice => :not_nil
      it_assigns_flash_cookie :error  => nil
      it_redirects_to do
        edit_admin_calendar_event_path(default_params.merge(:action => 'edit', :id => @section.events.last.id))
      end
    end
  end

  describe "PUT to :update" do
    action { post :update, default_params.merge(@params || {}).merge(:id => @event.id) }
    it_assigns :event
    it_guards_permissions :update, :calendar_event

    with :invalid_event_params do
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
    with :valid_event_params do
      it_assigns_flash_cookie :notice => :not_nil
      it_saves :event
      it_redirects_to do
        edit_admin_calendar_event_path(default_params.merge(:action => 'edit', :id => @event.id))
      end
    end
  end

  describe "DELETE to :destroy" do
    action { post :destroy, default_params.merge(:id => @event.id) }
    it_assigns :event => lambda { @event }
    it_guards_permissions :destroy, :calendar_event

    it_redirects_to { admin_calendar_events_path(@site, @section) }
    it_assigns_flash_cookie :notice => :not_nil
  end
end