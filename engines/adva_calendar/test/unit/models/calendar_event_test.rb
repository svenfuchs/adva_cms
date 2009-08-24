require File.dirname(__FILE__) + '/../../test_helper'

class CalendarEventTest < ActiveSupport::TestCase
  def setup
    super
    Time.stubs(:now).returns Time.utc(2009,2,3, 15,00,00)
    Date.stubs(:today).returns Date.civil(2009,2,3)

    @calendar = Calendar.find_by_permalink!('calendar-with-events')
    @event = @calendar.events.new(:title => 'A new event', :start_date => '2009-2-24 21:30',
      :end_date => '2009-2-25 01:30', :user_id => 1)
    @upcoming_event  = @calendar.events.find_by_permalink!('an-upcoming-event')
    @ongoing_event   = @calendar.events.find_by_permalink!('an-ongoing-event')
    @past_event      = @calendar.events.find_by_permalink!('a-past-event')
    @last_year_event = @calendar.events.find_by_permalink!('a-event-last-year')
  end

  test "00 time travelers paranoia" do
    Time.now.hour.should ==(15)
    event = CalendarEvent.find_by_permalink('a-past-event')
    event.start_date.should ==(Time.utc(2009,1,31, 15,00))
    event.end_date.should ==(Time.utc(2009,1,31, 17,00))
  end

  test "01 acts as a taggable" do
    Content.should act_as_taggable
  end

  test '02 should sanitize the body_html attribute' do
    CalendarEvent.should filter_attributes(:sanitize => :body_html)
  end

  test '03 should not sanitize the body and cached_tag_list attributes' do
    CalendarEvent.should filter_attributes(:except => [:body, :cached_tag_list])
  end

  test '04 should set a permalink' do
    @event.permalink.should be_nil
    @event.save!
    @event.permalink.should ==('a-new-event')
    @event.destroy
  end

  test "05 must have a title" do
    @event.title = nil
    @event.should_not be_valid
    @event.errors.on("title").should_not be_nil
    @event.errors.count.should == 1
  end

  test "06 must have start datetime" do
    @event.start_date = nil
    @event.should_not be_valid
    @event.errors.on("start_date").should_not be_nil
    @event.errors.count.should == 1
  end

  test "07 must have end datetime" do
    @event.end_date = nil
    CalendarEvent.require_end_date = true
    @event.require_end_date?.should == true
    @event.should_not be_valid
    @event.errors.on("end_date").should_not be_nil
    @event.errors.count.should == 1
  end

  test "08 must not require and end date if model says so" do
    CalendarEvent.require_end_date = false
    @event.end_date = nil
    @event.should be_valid
  end

  test "09 must have a start date earlier than the end date" do
    @event.end_date = @event.start_date - 1.day
    @event.should_not be_valid
    @event.errors.on("end_date").should_not be_nil
    @event.errors.count.should == 1
  end

  test "10 should have many categories" do
    @event.should have_many(:categories)
  end

  test "11 should have a location" do
    @event.should respond_to(:location)
  end

  test "12 should have a elapsed scope" do
    @calendar.events.elapsed.should == [@past_event, @last_year_event]
  end

  test "13 should have a recently added scope" do
    @calendar.events.recently_added.should == [@ongoing_event, @upcoming_event]
  end

  test "14 should have a published scope" do
    @calendar.events.published.should == [@upcoming_event, @ongoing_event, @past_event]
  end

  test "15 should have a by_categories scope" do
    jazz = @calendar.categories.find_by_permalink!('jazz')
    rock = @calendar.categories.find_by_permalink!('rock')
    punk = @calendar.categories.find_by_permalink!('punk')

    @calendar.events.by_categories(jazz.id).should == [@upcoming_event, @ongoing_event]
    @calendar.events.by_categories(rock.id).should == [@upcoming_event, @last_year_event]
    @calendar.events.by_categories(punk.id).should == [@past_event, @ongoing_event] # yep, see their start_dates
    @calendar.events.by_categories(jazz.id, rock.id).should == [@upcoming_event, @ongoing_event, @last_year_event]
  end

  test "16 from today on" do
    @calendar.events.upcoming.should == [@upcoming_event, @ongoing_event]
  end

  test "17 from tomorrow on" do
     @calendar.events.upcoming(Time.now + 1.day).should == [@upcoming_event]
  end

  test "18 for tomorrow only" do
    @calendar.events.upcoming(Time.now + 1.day, Time.now + 2.days).should == []
  end

  test "19 for last year" do
    @calendar.events.upcoming(Time.now - 1.year).should == [@last_year_event]
  end

  test "20 should have a search scope by title" do
    @calendar.events.search('upcoming', :title).should == [@upcoming_event]
  end

  test "21 should have a search scope by body" do
    @calendar.events.search('We', :body).should == [@upcoming_event, @last_year_event]
    @calendar.events.search('wisdom', :body).should == []
  end
end
