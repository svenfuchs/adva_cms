require File.dirname(__FILE__) + '/../spec_helper'

describe Activities::ArticleObserver do
  include SpecActivityHelper
  include FactoryScenario

  before :each do
    Site.delete_all
    @user = Factory   :user
    factory_scenario  :forum_with_board
    @topic = Factory  :topic, :section => @forum, :author => @user,
                      :title => 'Test topic', :body => 'This is a test topic'
    @topic.reload # all the hell breaks loose without this one.
  end

  it "should log a 'created' activity on save when the topic is a new_record" do
    @topic = Topic.new  :author => @user, :section => @forum,
                        :title => 'New topic', :body => 'This is a test topic!'
    expect_activity_new_with :actions => ['created']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end
  
  it "should log a 'renamed' activity on save when the topic already exists and will save a new title" do
    @topic.title = 'New topic title'
    expect_activity_new_with :actions => ['renamed']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end

  it "should log a 'stickied' activity on save when the topic is saved and marked as sticky" do
    @topic.sticky = true
    expect_activity_new_with :actions => ['stickied']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end

  it "should log a 'unstickied' activity on save when the topic is saved and marked as unsticky" do
    @topic.sticky = false
    expect_activity_new_with :actions => ['unstickied']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end

  it "should log a 'locked' activity on save when the topic is saved and marked as locked" do
    @topic.locked = true
    expect_activity_new_with :actions => ['locked']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end
  
  it "should log a 'unlocked' activity on save when the topic is saved and marked as unlocked" do
    @topic.stub!(:locked_changed?).and_return true
    expect_activity_new_with :actions => ['unlocked']
    Topic.with_observers('activities/topic_observer') { @topic.save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    expect_activity_new_with :actions => ['deleted']
    Topic.with_observers('activities/topic_observer') { @topic.destroy }
  end
end