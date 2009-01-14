require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  include Stubby, Matchers::ClassExtensions
  include FactoryScenario

  before :each do
    Site.delete_all
    @user   = Factory :user
    @site   = Factory :site
    @forum  = Forum.new(:title => 'Test forum')
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

  it "has a topics counter" do
    @forum.should have_one(:topics_counter)
  end

  it "has a comments counter" do
    @forum.should have_one(:comments_counter)
  end
  
  it "has option topics_per_page" do
    Forum.option_definitions.keys.should include(:topics_per_page)
  end
  
  it "has option comments_per_page" do
    Forum.option_definitions.keys.should include(:comments_per_page)
  end
  
  it "has option comments_per_page" do
    Forum.option_definitions.keys.should include(:latest_topics_count)
  end

  describe "associations" do
    it "has many boards" do
      @forum.should have_many(:boards)
    end

    it "has many topics" do
      @forum.should have_many(:topics)
    end

    it "has one recent topic" do
      @forum.should have_one(:recent_topic)
    end

    it "has one recent comment" do
      @forum.should have_one(:recent_comment)
    end
  end
  
  describe "validations" do
    describe "#topics_per_page" do
      it "passes when #topics_per_page is numerical" do
        @forum.topics_per_page = 10
        @forum.valid?.should be_true
      end
      
      it "fails when #topics_per_page is not numerical" do
        @forum.topics_per_page = 'ten'
        @forum.valid?.should be_false
      end
    end
    
    describe "#comments_per_page" do
      it "passes when #comments_per_page is numerical" do
        @forum.comments_per_page = 10
        @forum.valid?.should be_true
      end
      
      it "fails when #topics_per_page is not numerical" do
        @forum.comments_per_page = 'ten'
        @forum.valid?.should be_false
      end
    end
    
    describe "#latest_topics_count" do
      it "passes when #latest_topics_count is numerical" do
        @forum.latest_topics_count = 10
        @forum.valid?.should be_true
      end
      
      it "fails when #latest_topics_count is not numerical" do
        @forum.latest_topics_count = 'ten'
        @forum.valid?.should be_false
      end
    end
  end

  describe "methods" do
    describe "#recent_topic" do
      it "returns the most recent topic" do
        factory_scenario :forum_with_topics
        @topic.update_attribute(:last_updated_at, 1.month.ago)
        @forum.recent_topic.should == @recent_topic
      end
    end
    
    describe "#recent_comment" do
      it "returns the most recent topic" do
        stub_scenario :forum_with_three_comments
        @forum.recent_comment.should == @latest_comment
      end
    end
    
    describe "#latest_topics" do
      it "returns the ten most recently updated topics sorted by updated_at descending" do
        factory_scenario :forum_with_topics
        @topic.update_attribute(:last_updated_at, 1.month.ago)
        @forum.latest_topics_count = 1
        @forum.latest_topics.should == [@recent_topic]
      end
    end
    
    describe "#boardless_topics" do
      it "returns the all the forum topics that are not assigned to a board" do
        factory_scenario :forum_with_topics
        @forum.boardless_topics.size.should == [@topic, @recent_topic].size
      end
    end
    
    describe "Forum#content_type" do
      it ".returns 'Topic'" do # NOT SURE ABOUT THIS ...
        Forum.content_type.should == 'Board'
      end
    end
  end

  # describe "callbacks" do
  #   it "initializes the topics counter after create" do
  #     Forum.after_create.should include(:set_topics_count)
  #   end
  #   
  #   it "initializes the comments counter after create" do
  #     Forum.after_create.should include(:set_comments_count)
  #   end
  # end

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