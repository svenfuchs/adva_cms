require File.dirname(__FILE__) + '/../../spec_helper'

describe Event do
  include Matchers::ClassExtensions

  before :each do
    @calendar = Calendar.create!(:title => 'Concerts')
    @event = @calendar.events.new(:title => 'The Dodos', :startdate => '2008-11-24 21:30')
  end

  describe 'class extensions:' do
    it "acts as a taggable" do
      Content.should act_as_taggable
    end
    it 'sanitizes the body_html attribute' do
      Calendar::Event.should filter_attributes(:sanitize => :body_html)
    end

    it 'does not sanitize the body and cached_tag_list attributes' do
      Calendar::Event.should filter_attributes(:except => [:body, :cached_tag_list])
    end
  end

  describe 'callbacks' do
    it 'sets its published_at attribute to the current time before create' do
      Calendar::Event.before_create.should include(:set_published)
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
    it "should have a category"
    it "should have a location (country, city, adress)" do
      @event.should have_one(:location)
    end
    it "should have user bookmarks"
  end
  
  describe "named scopes" do
    it "should have a elapsed scope"
    it "should have a upcoming scope"
    it "should have a recently added scope"
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