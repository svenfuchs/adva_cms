require File.dirname(__FILE__) + '/../spec_helper'

describe "Events views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    Thread.current[:site] = stub_site

    assigns[:site] = stub_user
    assigns[:section] = stub_calendar
    assigns[:event] = @event = stub_calendar_event

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:datetime_with_microformat).and_return 'Once upon a time ...'
    template.stub!(:authorized_tag).and_return('authorized tags')

    template.stub!(:render).with hash_including(:partial => 'footer')
  end

  describe "index view" do
    before :each do
      assigns[:events] = @events = [@event, @event]
    end

    it "should render the event partial with a collection of events in list mode" do
      template.should_receive(:render).with :partial => 'event', :collection => @events, :locals => {:mode => :many}
      render "events/index"
    end
  end

  describe "show view" do
    before :each do
      assigns[:event] = @event
    end

    it "should render the event partial with an event in single mode" do
      template.should_receive(:render).with hash_including(:partial => 'events/event', :locals => {:mode => :single})
      render "events/show"
    end

    it "should display the edit link only for authorized user" do
      template.should_receive(:authorized_tag).with(:span, :update, @event).and_return('authorized tags')
      render "events/show"
    end 

  end

  describe "the event partial" do
    before :each do
      assigns[:event] = @event
    end

    it "should display an event" do
      render :partial => "events/event", :object => @event, :locals => {:mode => :many}
      response.should have_tag('div.events')
    end

    it "should list the event's tags" do
      template.should_receive(:links_to_content_tags)
      render "events/show"
    end

    it "should list the event's categories" do
      template.should_receive(:links_to_content_categories)
      render "events/show"
    end

    describe "with an event that has an excerpt" do
      before :each do
        @event.should_receive(:has_excerpt?).at_least(1).times.and_return(true)
      end

      describe "in list mode" do
        it "should display the event's excerpt" do
          @event.should_receive(:excerpt_html)
          render :partial => "events/event", :object => @event, :locals => {:mode => :many}
        end

        it "should not display the event's body" do
          @event.should_not_receive(:body_html)
          render :partial => "events/event", :object => @event, :locals => {:mode => :many}
        end

        it "should display a 'read more' link" do
          template.should_receive(:link_to_content).with(@event)
          render :partial => "events/event", :object => @event, :locals => {:mode => :many}
        end
      end

      describe "in single mode" do
        it "should display an event's excerpt" do
          @event.should_receive(:excerpt_html)
          render :partial => "events/event", :object => @event, :locals => {:mode => :single}
        end

        it "should display the event's body" do
          @event.should_receive(:body_html)
          render :partial => "events/event", :object => @event, :locals => {:mode => :single}
        end

        it "should not display a 'read more' link" do
          template.should_not_receive(:link_to_content).with('Read the rest of this entry', @event)
          render :partial => "events/event", :object => @event, :locals => {:mode => :single}
          response.should_not have_tag('a', :text => /Read/)
        end
      end
    end
  end
end