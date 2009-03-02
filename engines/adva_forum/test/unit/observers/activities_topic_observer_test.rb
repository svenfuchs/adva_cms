require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

if Rails.plugin?(:adva_activity)
  class ActivitiesTopicObserverTest < ActiveSupport::TestCase
    def setup
      super
      Topic.old_add_observer(@observer = Activities::TopicObserver.instance)
      @topic = Topic.first
    end
  
    def teardown
      super
      Topic.delete_observer(@observer)
    end
  
    test "logs a 'created' activity when the topic is a new_record" do
      topic = Topic.create! :title => 'title', :body => 'body', :author => User.first, 
                            :section => @topic.section

      topic.activities.first.actions.should == ['created']
    end
  
    test "logs a 'edited' activity when the topic already exists and will save a new title" do
      @topic.update_attributes! :title => 'title was edited'
      @topic.activities.first.actions.should == ['edited']
    end
  
    test "logs a 'sticked' activity when the topic is saved and marked as sticky" do
      @topic.update_attributes! :sticky => true
      @topic.activities.first.actions.should == ['sticked']
    end
  
    test "logs a 'unsticked' activity when the topic is saved and marked as unsticky" do
      sticky_topic.update_attributes! :sticky => false
      sticky_topic.activities.first.actions.should == ['unsticked']
    end
  
    test "logs a 'locked' activity when the topic is saved and marked as locked" do
      @topic.update_attributes! :locked => true
      @topic.activities.first.actions.should == ['locked']
    end
  
    test "logs a 'unlocked' activity when the topic is saved and marked as unsticky" do
      locked_topic.update_attributes! :locked => false
      locked_topic.activities.first.actions.should == ['unlocked']
    end
  
    test "logs a 'deleted' activity when the topic is destroyed" do
      @topic.destroy
      @topic.activities.first.actions.should == ['deleted']
    end
  
    def sticky_topic
      @sticky_topic ||= returning(@topic) do |topic|
        topic.update_attributes! :sticky => true
        topic.clear_changes!
        topic.activities.clear
        topic.reload
      end
    end
  
    def locked_topic
      @locked_topic ||= returning(@topic) do |topic|
        topic.update_attributes! :locked => true
        topic.clear_changes!
        topic.activities.clear
        topic.reload
      end
    end
  end
end