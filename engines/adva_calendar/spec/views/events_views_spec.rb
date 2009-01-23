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
      render "events/index"
      @calendar_events.should_receive(:each).at_least(:once) # as there are two events
      response.should have_tag('table#events')
      @calendar_events.each do |event|
        response.should have_tag("div#event-%i" % event.id)
      end
    end
    it "should add the all_day class for events" do
      @calendar_events.first.stub!(:all_day?).and_return(true)
      render "events/index"
      response.should have_tag('tr#calendar_event_%i.all_day' % @calendar_events.first.id)
    end
  end
  

  describe "show view" do
    before :each do
      assigns[:event] = @calendar_event
    end

    it "should display the edit link only for authorized user" do
      render "events/show"
      template.should_receive(:authorized_tag).with(:span, :update, @calendar_event).and_return('authorized tags')
    end

    it "should render the event's permalink" do
      render "events/show"
      template.should_receive(:link_to_event).with(@calendar_event)
    end

    it "should list the event's tags" do
      render "events/show"
      template.should_receive(:links_to_content_tags)
    end

    it "should list the event's categories" do
      render "events/show"
      template.should_receive(:links_to_content_categories)
    end
    
    it "should show dates" do
      render "events/show"
      template.should_receive(:datetime_with_microformat).with(@calendar_event.start_date, {:format=>:long}).exactly(2)
      template.should_receive(:datetime_with_microformat).with(@calendar_event.end_date, {:format=>:long}).exactly(2)
    end
    it "should show 'all day'" do
      @calendar_event.stub!(:all_day?).and_return(true)
      render "events/show"
      template.should_not_receive(:datetime_with_microformat).with(@calendar_event.start_date, {:format=>:long})
      template.should_not_receive(:datetime_with_microformat).with(@calendar_event.end_date, {:format=>:long})
    end
  end
end