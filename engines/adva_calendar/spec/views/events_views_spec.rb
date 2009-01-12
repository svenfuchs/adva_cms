require File.dirname(__FILE__) + '/../spec_helper'

describe "Events views:" do
  include SpecViewHelper
  include ContentHelper
  include EventsHelper

  before :each do
    assigns[:site] = stub_user
    assigns[:section] = assigns[:calendar] = @section = @calendar = stub_calendar
    @calendar_event = stub_calendar_event
    @calendar_events = [@calendar_event, @calendar_event]
    @calendar_events.stub!(:total_pages).and_return 1

    # any way to remove those two stubs?
    Section.stub!(:find).and_return @section

    template.stub!(:link_to_event).and_return 'link_to_event'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:datetime_with_microformat).and_return 'Once upon a time ...'
    template.stub!(:authorized_tag).and_return('authorized tags')    
    template.stub!(:current_timespan).and_return([Date.new(2008,12,01), Date.new(2008,12,31)])
    template.stub!(:current_timespan_format).and_return('%Y %m %d')
    template.stub!(:calendar_events_path).and_return '/calendars/1/events/2008/12'

    template.stub!(:render).with hash_including(:partial => 'footer')
  end

  describe "index view" do
    before :each do
      assigns[:events] = @calendar_events
    end

    it "should render the list of events" do
      @calendar_events.should_receive(:each).twice # as there are two events
      render "events/index"
      response.should have_tag('table#events')
      @calendar_events.each do |event|
        response.should have_tag("div#event-%i" % event.id)
      end
    end
  end

  describe "show view" do
    before :each do
      assigns[:event] = @calendar_event
    end

    it "should display the edit link only for authorized user" do
      template.should_receive(:authorized_tag).with(:span, :update, @calendar_event).and_return('authorized tags')
      render "events/show"
    end

    it "should render the event's permalink" do
      render "events/show"
      template.should_receive(:link_to_event).with(@calendar_event)
    end

    it "should list the event's tags" do
      template.should_receive(:links_to_content_tags)
      render "events/show"
    end

    it "should list the event's categories" do
      template.should_receive(:links_to_content_categories)
      render "events/show"
    end
  end
end