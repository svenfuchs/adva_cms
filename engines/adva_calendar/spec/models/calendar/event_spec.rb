require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar::Event do
  include Stubby, Matchers::ClassExtensions

  before :each do
    @calendar = stub_calendar
    @event = @calendar.events.new :author => stub_user
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
    it 'sets its  attribute to the current time before create' do # TODO why does it do this??
      Calendar::Event.before_create.should include(:set_published)
    end

    it 'initializes the title from the permalink for new records that do not have a title' do
      new_event = Calendar::.new :permalink => 'something-new'
      new_event.title.should == 'Something new'
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
    it "should have a host"
    it "should have a location (country, city, adress)"
    it "should have user bookmarks"
  end
  
  describe "named scopes" do
    it "should have a recent scope"
    it "should have a upcoming scope"
    it "should have a recently added scope"
  end
  
end