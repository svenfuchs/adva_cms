require File.dirname(__FILE__) + '/../../test_helper'

class CalendarTest < ActiveSupport::TestCase
  def setup
    super
    @calendar = Calendar.find_by_permalink!('calendar-with-events')
    @calendar.events.update_all(:published_at => Time.now)
    @calendar_without_events = Calendar.find_by_permalink!('calendar-without-events')
  end

  test "01 is a kind of Section" do
    @calendar.should be_kind_of(Section)
  end

  test "02 content_type returns 'CalendarEvent'" do
    Calendar.content_type.should == 'CalendarEvent'
  end

  test "03 days_in_month_with_events for month with no events" do
    @calendar.days_in_month_with_events(Date.civil(1999,12)).should be_empty
  end

  test "04 days_in_month_with_events with events" do
    @calendar.instance_variable_set('@days_in_month_with_events', {})
    @calendar.days_in_month_with_events(Date.civil(2009,2,1)).should ==[Date.civil(2009,2,1), Date.civil(2009,2,2), Date.civil(2009,2,3), Date.civil(2009,2,8)].flatten.compact.sort
    @calendar.days_in_month_with_events(Date.civil(2009,1,1)).should ==[Date.civil(2009,1,29), Date.civil(2009,1,30), Date.civil(2009,1,31)]
  end

  test "05 days_in_month_with_events with less events" do
    @calendar.events.update_all(:published_at => nil)
    @calendar.instance_variable_set(:@days_in_month_with_events, nil)
    @calendar.days_in_month_with_events(Date.civil(2009,1,1)).should == []
    @calendar.days_in_month_with_events(Date.civil(2009,2,1)).should == []

    # and now publish the second one
    @calendar.events.find_by_permalink('a-past-event').update_attribute(:published_at, Time.now)
    @calendar.instance_variable_set(:@days_in_month_with_events, {})
    @calendar.days_in_month_with_events(Date.civil(2009,1)).should == [Date.civil(2009, 1, 31)]
    @calendar.days_in_month_with_events(Date.civil(2009,2)).should == []
  end
end