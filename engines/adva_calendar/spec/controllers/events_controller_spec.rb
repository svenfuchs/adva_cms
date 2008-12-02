require File.dirname(__FILE__) + "/../spec_helper"

calendar_path = '/events/1'
calendar_day_path = '/events/1/2008/11/27'
calendar_month_path = '/events/1/2008/11'
calendar_year_path = '/events/1/2008'
formatted_calendar_path = '/events/1.ics'
event_path = '/event/1/1'
formatted_event_path = '/event/1/1.ics'
category_path = '/events/1/categories/2'
formatted_category_path = '/events/1/categories/2.ics'

cached_paths = calendar_path, calendar_day_path, calendar_month_path, calendar_year_path, formatted_calendar_path, event_path, category_path, formatted_category_path

ics_paths = formatted_calendar_path, formatted_category_path

describe EventsController do
  include SpecControllerHelper

  before :each do
    stub_scenario :calendar_with_events

    controller.stub!(:calendar_path).and_return calendar_path
    controller.stub!(:event_path).and_return event_path

    controller.stub!(:has_permission?).and_return true
  end

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  # TODO these overlap with specs in calendar_routes_spec
  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get, calendar_path, :index
      route.it_maps :get, formatted_calendar_path, :index, :format => 'ics'
      route.it_maps :get, event_path, :show,    :id => '1'
      route.it_maps :get, category_path, :index, :category_id => '2'
      route.it_maps :get, formatted_category_path, :index, :format => 'ics', :category_id => '2'
    end
  end
  
  cached_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_gets_page_cached
    end
  end
  
  describe "GET to #{calendar_path}" do
    act! { request_to(:get, calendar_path) }
    it_assigns :timespan, [Date.today, Date.today.end_of_month]
    it "should call Event.upcoming from to today to end of month" do
      @section.events.should_receive(:upcoming, {Date.today, Date.today.end_of_month})
      act!
    end
  end
  describe "GET to :index with a specific day" do
    act! { request_to(:get, calendar_day_path) }
    it_assigns :timespan, [Date.new(2008, 11, 27), Date.new(2008, 11, 27).end_of_day]
    it "should call Event.upcoming" do
      @section.events.should_receive(:upcoming, {Date.new(2008, 11, 27), Date.new(2008, 11, 27).end_of_day})
      act!
    end
  end
  
  describe "GET to :index for recently updated events" do
    act! { request_to(:get, {:action => :index, :recent => true }) }
    it "should call Event.recent" do
      @section.event.should_receive(:recent)
      act!
    end
  end
  describe "GET to :index for elapsed updated events" do
    act! { request_to(:get, {:action => :index, :elapsed => true }) }
    it "should call Event.elapsed" do
      @section.event.should_receive(:elapsed)
      act!
    end
  end

  describe "GET to :index for a category" do
    act! { request_to(:get, category_path) }
    it "should set category" do
      @section.categories.should_receive(:find, {:category_id => '2' })
      act!
    end
  end
end

describe EventsController, 'calendar format' do
  include SpecControllerHelper

  before :each do
    stub_scenario :calendar_with_events
    controller.stub!(:has_permission?).and_return true
  end

  ics_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'events/index', :format => :ics
    end
  end
end

describe EventsController, 'page_caching' do
  include SpecControllerHelper

  before :each do
    @event_sweeper = EventsController.filter_chain.find EventSweeper.instance
    @category_sweeper = EventsController.filter_chain.find CategorySweeper.instance
    @tag_sweeper = EventsController.filter_chain.find TagSweeper.instance
  end

  it "activates the EventSweeper as an around filter" do
    @event_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the EventSweeper to observe Event create, update and destroy events" do
    @event_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'update']
  end

  it "activates the CategorySweeper as an around filter" do
    @category_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the CategorySweeper to observe Event create, update and destroy events" do
    @category_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'update']
  end

  it "activates the TagSweeper as an around filter" do
    @tag_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the TagSweeper to observe Event create, update and destroy events" do
    @tag_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'update']
  end

  it "tracks read access for a bunch of models for the :index action page caching" do
    EventsController.track_options[:index].should == ['@event', '@events', '@category', {"@section" => :tag_counts, "@site" => :tag_counts}]
  end

  it "page_caches the :show action" do
    cached_page_filter_for(:show).should_not be_nil
  end

  it "tracks read access for a bunch of models for the :show action page caching" do
    EventsController.track_options[:show].should == ['@event', '@events', '@category', {"@section" => :tag_counts, "@site" => :tag_counts}]
  end

end

describe "EventSweeper" do
  include SpecControllerHelper
  controller_name 'Events'

  before :each do
    stub_scenario :calendar_with_events
    @sweeper = EventSweeper.instance
  end

  it "observes Event" do
    ActiveRecord::Base.observers.should include(:event_sweeper)
  end

  it "should expire pages that reference when an event was saved" do
    @sweeper.should_receive(:expire_cached_pages_by_reference).with(@event)
    @sweeper.after_save(@event)
  end
end