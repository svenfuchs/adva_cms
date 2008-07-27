require File.dirname(__FILE__) + '/../spec_helper'

describe Counter do
  include Stubby
  
  before :each do
    @forum = Forum.new :title => 'forum', :site => stub_site
    @forum.stub!(:build_path)
    @forum.save!
    
    @topic_attributes = {:section => @forum, :title => 'title', :body => 'body', :author => stub_user, :last_author => stub_user, :last_author_name => 'name'}
  end
  
  it "has_one topics_count" do
    @forum.should have_one(:topics_counter)
  end
  
  it "responds to :topics_count" do
    @forum.should respond_to(:topics_count)
  end
  
  it "#topics_count works as shortcut to #topics_counter.count" do
    @forum.topics_counter.count = 5
    @forum.topics_count.should == 5
  end
  
  it "after create it has a counter initialized and saved" do
    @forum.topics_counter.should_not be_nil
  end
  
  it "increment! is called after a topic has been created" do
    @forum.topics_counter.should_receive(:increment!)
    Topic.create! @topic_attributes
  end
  
  it "actually increments its counter value after a topic has been created" do
    @forum.topics_counter.update_attributes :count => 0
    Topic.create! @topic_attributes
    @forum.topics_counter.count.should == 1
  end
  
  it "decrement! is called after a topic has been created" do
    topic = Topic.create!(@topic_attributes)
    @forum.topics_counter.should_receive(:decrement!)
    topic.destroy
  end
  
  it "actually increments its counter value after a topic has been created" do
    topic = Topic.create! @topic_attributes
    @forum.topics_counter.update_attributes :count => 1
    topic.destroy
    @forum.topics_counter.count.should == 0
  end
end