require File.dirname(__FILE__) + '/../../spec_helper'

describe Event do
  include Matchers::ClassExtensions

  before :each do
    @calendar = Calendar.create!(:title => 'Concerts')
    @event = @calendar.events.create!
  end

  describe 'class extensions:' do
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
  describe '#accept_comments?' do
    it 'does not accept comments' do
      @event.should_receive(:accept_comments?).and_return false
    end
  end
  
  describe 'validations' do
    it "should have start datetime"
    it "should have a start date earlier than the end date"
  end
  
  describe "relations" do
    it "should belong to a category"
    it "should belong to a location (country, city, adress)"
    it "should have user bookmarks"
    it "should have tags"
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