require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  include Stubby, Matchers::ClassExtensions
  
  before :each do
    scenario :counter
    @forum = Forum.new
  end
  
  it "is a kind of Section" do
    @forum.should be_kind_of(Section)
  end
  
  it "acts as a commentable" do
    Forum.should act_as_commentable
  end
  
  it "has a topics counter" do
    Forum.should have_counter(:topics)
  end
    
  it "has default permissions for topics and comments" do
    Forum.default_permissions.should == 
      { :topic =>   { :create => :user, :update => :user, :destroy => :moderator, :moderate => :moderator }, 
        :comment => { :create => :user, :update => :author, :destroy => :author} }
  end
  
  describe "associations" do
    it "has many topics" do
      @forum.should have_many(:topics)
    end    
    
    it "has one recent topic" do
      @forum.should have_one(:recent_topic)
    end
    
    it "#recent_topic returns the most recent topic" do
      scenario :two_topics
      @forum.recent_topic.should == @latest_topic
    end
    
    it "has one recent comment" do
      @forum.should have_one(:recent_comment)
    end
    
    it "#recent_comment returns the most recent topic" do
      scenario :three_comments
      @forum.recent_comment.should == @latest_comment
    end
    
    it "has a topics counter" do
      @forum.should have_one(:topics_counter)
    end
    
    it "has a comments counter" do
      @forum.should have_one(:comments_counter)
    end
  end
  
  describe "callbacks" do
    # it "initializes the topics counter after create" do
    #   Forum.after_create.should include(:set_topics_count)
    # end
    # 
    # it "initializes the comments counter after create" do
    #   Forum.after_create.should include(:set_comments_count)
    # end
  end
  
  # describe '#after_topic_update' do
  #   before :each do
  #     @forum.topics.stub!(:count)
  #     @forum.comments.stub!(:count)
  #     @forum.stub!(:topics_count).and_return stub_counter
  #     @forum.stub!(:comments_count).and_return stub_counter
  #   end
  #   
  #   it "updates the topics counter" do
  #     @forum.topics_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  # 
  #   it "updates the comments counter" do
  #     @forum.comments_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  # end
end