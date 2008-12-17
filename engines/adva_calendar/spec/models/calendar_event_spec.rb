require File.dirname(__FILE__) + '/../spec_helper'

describe CalendarEvent do
  include Matchers::ClassExtensions

  before :each do
    @calendar = Calendar.create!(:title => 'Concerts')
    @event = @calendar.events.new(:title => 'The Dodos', :startdate => '2008-11-24 21:30',
      :user_id => 1)
  end

  describe 'class extensions:' do
    it "acts as a taggable" do
      Content.should act_as_taggable
    end
    it 'sanitizes the body_html attribute' do
      CalendarEvent.should filter_attributes(:sanitize => :body_html)
    end

    it 'does not sanitize the body and cached_tag_list attributes' do
      CalendarEvent.should filter_attributes(:except => [:body, :cached_tag_list])
    end
  end

  describe 'callbacks' do
    it 'sets its published_at attribute to the current time before create' do
      CalendarEvent.before_create.should include(:set_published)
    end
  end
  
  describe 'validations' do
    before :each do
      @event.should be_valid
      @event.save!.should be_true
      @event.reload
    end

    it "must have a title" do
      @event.title = nil
      @event.should_not be_valid
      @event.errors.on("title").should be
      @event.errors.count.should be(1)
    end

    it "must have start datetime" do
      @event.startdate = nil
      @event.should_not be_valid
      @event.errors.on("startdate").should be
      @event.errors.count.should be(1)
    end
    it "must have a start date earlier than the end date" do
      @event.enddate = @event.startdate - 1.day
      @event.should_not be_valid
      @event.errors.on("enddate").should be
      @event.errors.count.should be(1)
    end
  end
  
  describe "relations" do
    it "should have many categories" do
      @event.should have_many(:categories)
    end
    it "should have a location" do
      @event.should belong_to(:location)
    end
    it "should have user bookmarks"
  end
  
  describe "named scopes" do
    before do
      @calendar.events.delete_all
      @cat1 = @calendar.categories.create!(:title => 'cat1')
      @cat2 = @calendar.categories.create!(:title => 'cat2')
      @cat3 = @calendar.categories.create!(:title => 'cat3')
      @elapsed_event = @calendar.events.create!(:title => 'Gameboy Music Club', 
          :startdate => Time.now - 1.day, :user_id => 1, :categories => [@cat1, @cat2]).reload
      @elapsed_event2 = @calendar.events.create!(:title => 'Mobile Clubbing', 
          :startdate => Time.now - 5.hours,  :enddate => Time.now - 3.hour, :user_id => 1, :categories => [@cat1, @cat2]).reload
      @upcoming_event = @calendar.events.create!(:title => 'Jellybeat', 
          :startdate => Time.now + 4.hours, :user_id => 1, :categories => [@cat2, @cat3]).reload
      @running_event = @calendar.events.create!(:title => 'Vienna Jazz Floor 08', 
          :startdate => Time.now - 1.month, :enddate => Time.now + 9.days, :user_id => 1, :categories => [@cat1, @cat3]).reload
      @real_old_event = @calendar.events.create!(:title => 'Vienna Jazz Floor 07', 
          :startdate => Time.now - 1.year, :enddate => Time.now - 11.months, :user_id => 1, :draft => true, :categories => [@cat2]).reload
#      @calendar.reload
    end
    describe "upcoming scope" do
      it "from today on" do
        @calendar.events.upcoming.should ==[@running_event, @upcoming_event]
      end
      it "from tomorrow on" do
        @calendar.events.upcoming(Date.today + 1.day).should ==[@running_event]
      end
      it "for last month" do
        @calendar.events.upcoming(Date.today - 1.year).should ==[@real_old_event]
      end
    end
    it "should have a elapsed scope" do
      @calendar.events.elapsed.should ==[@elapsed_event2, @elapsed_event, @real_old_event]
    end
    it "should have a recently added scope" do
      @calendar.events.recently_added.should ==[@upcoming_event, @running_event]
    end
    it "should have a search scope" do
      @calendar.events.upcoming.search('Jazz', :title).should ==[@running_event]
      @calendar.events.search('Jazz', :title).should ==[@running_event, @real_old_event]
    end
    it "should have a published scope" do
      @calendar.events.published.should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @running_event]
    end
    it "should have a by_categories scope" do
      @calendar.events.by_categories(@cat1.id).should ==[@elapsed_event, @elapsed_event2, @running_event]
      @calendar.events.by_categories(@cat2.id).should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @real_old_event]
      @calendar.events.by_categories(@cat3.id).should ==[@upcoming_event, @running_event]
      @calendar.events.by_categories(@cat1.id, @cat2.id).should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @running_event, @real_old_event]
    end
  end
  
  describe "recurring events" do
    it "should have a parent event"
    it "should support daily events"
    it "should support weekly events"
    it "should support monthly events"
    it "should support yearly events"
    it "should support weekdays"
  end
end