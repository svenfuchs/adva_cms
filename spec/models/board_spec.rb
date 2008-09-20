require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  include Stubby, Matchers::ClassExtensions

  before :each do
    @board = Board.new
  end

  it "acts as a commentable" do
    Board.should act_as_commentable
  end

  it "has a topics counter" do
    Board.should have_counter(:topics)
  end

  describe "associations" do
    it "has many topics" do
      @board.should have_many(:topics)
    end

    it "has one recent topic" do
      @board.should have_one(:recent_topic)
    end

    # it "#recent_topic returns the most recent topic" do
    #   scenario :board_with_two_topic_fixtures
    #   @board.recent_topic.should == @latest_topic
    # end

    it "has one recent comment" do
      @board.should have_one(:recent_comment)
    end

    it "#recent_comment returns the most recent topic" do
      scenario :board_with_three_comments
      @board.recent_comment.should == @latest_comment
    end

    it "has a topics counter" do
      @board.should have_one(:topics_counter)
    end

    it "has a comments counter" do
      @board.should have_one(:comments_counter)
    end
  end

  describe "callbacks" do
    # it "initializes the topics counter after create" do
    #   Board.after_create.should include(:set_topics_count)
    # end
    #
    # it "initializes the comments counter after create" do
    #   Board.after_create.should include(:set_comments_count)
    # end
  end

  # describe '#after_topic_update' do
  #   before :each do
  #     @board.topics.stub!(:count)
  #     @board.comments.stub!(:count)
  #     @board.stub!(:topics_count).and_return stub_counter
  #     @board.stub!(:comments_count).and_return stub_counter
  #   end
  #
  #   it "updates the topics counter" do
  #     @board.topics_count.should_receive(:set).any_number_of_times
  #     @board.send :after_topic_update, @topic
  #   end
  #
  #   it "updates the comments counter" do
  #     @board.comments_count.should_receive(:set).any_number_of_times
  #     @board.send :after_topic_update, @topic
  #   end
  # end

  describe "counters on a board with three comments on one topic" do
    before :each do
      scenario :board_with_three_comments
    end

    it "should have one board" do
      @forum.boards.count.should == 1
    end

    it "should have three topics" do
      @board.topics.count.should == 1
    end

    it "should have three comments" do
      @board.comments.count.should == 3
    end

    it "should have counted the comments" do
      @board.comments_count.should == 3
    end

    it "should have counted the topics" do
      @board.topics_count.should == 1
    end
  end

  describe "cached attributes on a board with three comments on one topic" do
    before :each do
      scenario :board_with_three_comments
    end

    it "should have last_comment_id set" do
      @board.last_comment_id.should == @latest_comment.id
    end

    it "should have last_updated_at set" do
      @board.last_updated_at.should == @one_day_ago
    end

    it "should have last_author set" do
      @board.last_author.should == stub_user
    end
  end
end