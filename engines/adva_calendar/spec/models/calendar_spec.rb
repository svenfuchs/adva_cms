require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  before :each do
    @calendar = Calendar.new(:title => 'A calendar')
  end
  
  it "should be valid" do
    @calendar.should be_valid
  end
  
  it "is a kind of Section" do
    @calendar.should be_kind_of(Section)
  end

  it "has many events" do
    @calendar.should have_many(:events)
  end

  it "has many categories" do
    @calendar.should have_many(:categories)
  end

  it ".content_type returns 'CalendarEvent'" do
    Calendar.content_type.should == 'CalendarEvent'
  end
  
  describe ":days_in_month_with_events" do
    before do
      args = {:user_id => 1, :title => 'Event', :location_id => 1}
      @calendar_with_events = Calendar.create!(:title => 'Another calendar')
      @event1 = @calendar_with_events.events.create!(args.merge(:start_date => '2008-11-27'))
      @event2 = @calendar_with_events.events.create!(args.merge(:start_date => '2008-11-24', :end_date => '2008-11-26'))
      @event3 = @calendar_with_events.events.create!(args.merge(:start_date => '2007-11-27'))
      @event4 = @calendar_with_events.events.create!(args.merge(:start_date => '2008-10-30', :end_date => '2008-11-02'))
    end
    it "should be empty for an empty month" do
      @calendar_with_events.days_in_month_with_events(Date.civil(1999,12)).should be_empty
    end
    it "should return a list for months with events" do
      @calendar_with_events.days_in_month_with_events(Date.civil(2008,11)).should ==Range.new(Date.civil(2008,11,24), Date.civil(2008,11,27)).to_a
      @calendar_with_events.days_in_month_with_events(Date.civil(2008,10)).should ==[Date.civil(2008,10,30), Date.civil(2008,10,31)]
    end
  end
end