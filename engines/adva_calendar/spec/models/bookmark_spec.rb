require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do
  before :each do
    @user = stub_user
    @event = stub_event
    @bookmark = Bookmark.new(:event => @event, :user => @user)
  end

  it "should be valid" do
    @bookmark.should be_valid
  end
  it "should belong to an user" do
    @bookmark.should have_one(:user)
  end
  
  it "should belong to an event" do
    @bookmark.should have_one(:event)    
  end
end