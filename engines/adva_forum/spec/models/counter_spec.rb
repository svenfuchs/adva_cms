require File.dirname(__FILE__) + '/../spec_helper'

describe "Forum counters (with boards)" do
  before :each do
    a_forum_with_two_boards_and_a_bunch_of_topics_and_posts!
  end
  
  it "decrements Forum#topics_count by board.topics_count when a board is deleted (only happens if this is not the last board)" do
    @board_1.destroy
    @forum.topics_count.should == 0
  end
  
  it "decrements Forum#comments_count by board.comments_count when a board is deleted (only happens if this is not the last board)" do
    @board_1.destroy
    @forum.comments_count.should == 0
  end
  
  it "increments Forum#topics_count when a new topic is created" do
    @board_1.topics.post(@user, :title => 'topic', :body => 'body')
    @forum.topics_count.should == 2
  end

  it "decrements Forum#topics_count when a topic is deleted" do
    @topic.destroy
    @forum.topics_count.should == 0
  end
  
  it "increments Forum#comments_count when a new topic is created" do
    @board_1.topics.post(@user, :title => 'topic', :body => 'body')
    @forum.comments_count.should == 3
  end
  
  it "increments Forum#comments_count when a new post is created" do
    @topic.reply(@user, :body => 'body').save
    @forum.comments_count.should == 3
  end
  
  it "decrements Forum#comments_count when a post is deleted" do
    @topic.comments.last.destroy
    @forum.comments_count.should == 1
  end
  
  it "decrements Forum#comments_count by topic.comments_count when a topic is deleted" do
    @topic.destroy
    @forum.comments_count.should == 0
  end
  
  it "increments Board#topics_count when a new topic is created" do
    @board_1.topics.post(@user, :title => 'topic', :body => 'body')
    @board_1.topics_count.should == 2
  end

  it "decrements Board#topics_count when a topic is deleted" do
    @topic.destroy
    @board_1.topics_count.should == 0
  end
  
  it "increments Board#comments_count when a new topic is created" do
    @board_1.topics.post(@user, :title => 'topic', :body => 'body')
    @board_1.comments_count.should == 3
  end
  
  it "increments Board#comments_count when a new post is created" do
    @topic.reply(@user, :body => 'body').save
    @board_1.comments_count.should == 3
  end
  
  it "decrements Board#comments_count when a post is deleted" do
    @topic.comments.last.destroy
    @board_1.comments_count.should == 1
  end
  
  it "decrements Board#comments_count by topic.comments_count when a topic is deleted" do
    @topic.destroy
    @board_1.comments_count.should == 0
  end
  
  it "decrements the old board's topics_count when a topic is moved from one board to another" do
    @topic.send :move_to_board, @board_2.id
    @board_1.topics_count.should == 0
  end
  
  it "decrements the old board's comments_count by topic.comments_count when a topic is moved from one board to another" do
    @topic.send :move_to_board, @board_2.id
    @board_1.comments_count.should == 0
  end

  it "increments the target_board's topics_count when a topic is moved to a board" do
    @topic.send :move_to_board, @board_2.id
    @board_2.topics_count.should == 1
  end
  
  it "increments the target_board's comments_count by topic.comments_count when a topic is moved to a board" do
    @topic.send :move_to_board, @board_2.id
    @board_2.comments_count.should == 2
  end
  
  it "increments Topic#comments_count when a new post is created" do
    @topic.reply(@user, :body => 'body').save
    @topic.comments_count.should == 3
  end
  
  it "decrements Topic#comments_count when a post is deleted" do
    @topic.comments.last.destroy
    @topic.comments_count.should == 1
  end
  
  def a_forum_with_two_boards_and_a_bunch_of_topics_and_posts! 
    Site.delete_all
    
    @user = Factory :user
    @site = Factory :site
    @forum = Factory :forum, :site => @site
    
    @board_1 = Factory :board, :section => @forum
    @board_2 = Factory :board, :section => @forum
    
    @topic = Factory :topic, :section => @forum, :author => @user
    @topic.comments << Factory(:post, :author => @user, :commentable => @topic, :section => @forum, :board => @board_1)
    @topic.comments << Factory(:post, :author => @user, :commentable => @topic, :section => @forum, :board => @board_1)

    @board_1.topics << @topic

    @forum.topics_counter.set(1)
    @forum.comments_counter.set(2)
    @board_1.topics_counter.set(1)
    @board_1.comments_counter.set(2)
    @board_2.topics_counter.set(0)
    @board_2.comments_counter.set(0)
    @topic.comments_counter.set(2)
    
    [@forum, @board_1, @board_2, @topic].each { |record| record.reload }
  end
end

describe "Forum counters (without boards)" do
  before :each do
    a_forum_with_a_bunch_of_topics_and_posts!
  end
  
  it "increments Forum#topics_count when a new topic is created" do
    @forum.topics.post(@user, :title => 'topic', :body => 'body')
    @forum.topics_count.should == 2
  end

  it "decrements Forum#topics_count when a topic is deleted" do
    @topic.destroy
    @forum.topics_count.should == 0
  end
  
  it "increments Forum#comments_count when a new topic is created" do
    @forum.topics.post(@user, :title => 'topic', :body => 'body')
    @forum.comments_count.should == 3
  end
  
  it "increments Forum#comments_count when a new post is created" do
    @topic.reply(@user, :body => 'body').save
    @forum.comments_count.should == 3
  end
  
  it "decrements Forum#comments_count when a post is deleted" do
    @topic.comments.last.destroy
    @forum.comments_count.should == 1
  end
  
  it "decrements Forum#comments_count by topic.comments_count when a topic is deleted" do
    @topic.destroy
    @forum.comments_count.should == 0
  end
  
  it "increments Topic#comments_count when a new post is created" do
    @topic.reply(@user, :body => 'body').save
    @topic.comments_count.should == 3
  end
  
  it "decrements Topic#comments_count when a post is deleted" do
    @topic.comments.last.destroy
    @topic.comments_count.should == 1
  end
  
  def a_forum_with_a_bunch_of_topics_and_posts! 
    Site.delete_all
    
    @user = Factory :user
    @site = Factory :site
    @forum = Factory :forum, :site => @site
    
    @topic = Factory :topic, :section => @forum, :author => @user
    @topic.comments << Factory(:post, :author => @user, :commentable => @topic, :section => @forum)
    @topic.comments << Factory(:post, :author => @user, :commentable => @topic, :section => @forum)

    @forum.topics_counter.set(1)
    @forum.comments_counter.set(2)
    @topic.comments_counter.set(2)
    
    [@forum, @topic].each { |record| record.reload }
  end
end