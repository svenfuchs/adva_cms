require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ForumWithBoardsCounterTest < ActiveSupport::TestCase
  def setup
    super
    @forum = Forum.find_by_title 'a forum with boards'
    @board = @forum.boards.find_by_title 'a board'
    @another_board = @forum.boards.find_by_title 'another board'
    @topic = @board.topics.find_by_title 'a board topic'
    @user = User.first
  end

  test "decrements Forum#topics_count by board.topics_count when a board is deleted that is not the last board" do
    @board.destroy
    @forum.topics_count.should == 0
  end
  
  test "decrements Forum#comments_count by board.comments_count when a board is deleted that is not the last board" do
    @board.destroy
    @forum.comments_count.should == 0
  end
  
  test "increments Forum#topics_count when a new topic is created" do
    assert_difference '@forum.reload.topics_count', 1 do
      @board.topics.post @user, :title => 'topic', :body => 'body'
    end
  end
  
  test "decrements Forum#topics_count when a topic is deleted" do
    assert_difference '@forum.reload.topics_count', -1 do
      @topic.destroy
    end
  end
  
  test "increments Forum#comments_count when a new topic is created" do
    assert_difference '@forum.reload.comments_count', 1 do
      @board.topics.post @user, :title => 'topic', :body => 'body'
    end
  end
  
  test "increments Forum#comments_count when a new post is created" do
    assert_difference '@forum.reload.comments_count', 1 do
      @topic.reply(@user, :body => 'body').save
    end
  end
  
  test "decrements Forum#comments_count when a post is deleted" do
    assert_difference '@forum.reload.comments_count', -1 do
      @topic.comments.last.destroy
    end
  end
  
  test "decrements Forum#comments_count by topic.comments_count when a topic is deleted" do
    assert_difference '@forum.reload.comments_count', -@topic.comments_count do
      @topic.destroy
    end
  end
  
  test "increments Board#topics_count when a new topic is created" do
    assert_difference '@board.reload.topics_count', 1 do
      @board.topics.post @user, :title => 'topic', :body => 'body'
    end
  end
  
  test "decrements Board#topics_count when a topic is deleted" do
    assert_difference '@board.reload.topics_count', -1 do
      @topic.destroy
    end
  end
  
  test "increments Board#comments_count when a new topic is created" do
    assert_difference '@board.reload.comments_count', 1 do
      @board.topics.post @user, :title => 'topic', :body => 'body'
    end
  end
  
  test "increments Board#comments_count when a new post is created" do
    assert_difference '@board.reload.comments_count', 1 do
      @topic.reply(@user, :body => 'body').save
    end
  end
  
  test "decrements Board#comments_count when a post is deleted" do
    assert_difference '@board.reload.comments_count', -1 do
      @topic.comments.last.destroy
    end
  end
  
  test "decrements Board#comments_count by topic.comments_count when a topic is deleted" do
    assert_difference '@board.reload.comments_count', -@topic.comments_count do
      @topic.destroy
    end
  end
  
  test "decrements the old board's topics_count when a topic is moved from one board to another" do
    assert_difference '@board.reload.topics_count', -1 do
      @topic.send :move_to_board, @another_board.id
    end
  end
  
  test "decrements the old board's comments_count by topic.comments_count when a topic is moved from one board to another" do
    assert_difference '@board.reload.comments_count', -@topic.comments_count do
      @topic.send :move_to_board, @another_board.id
    end
  end
  
  test "increments the target_board's topics_count when a topic is moved to a board" do
    assert_difference '@another_board.reload.topics_count', 1 do
      @topic.send :move_to_board, @another_board.id
    end
  end
  
  test "increments the target_board's comments_count by topic.comments_count when a topic is moved to a board" do
    assert_difference '@another_board.reload.comments_count', @topic.comments_count do
      @topic.send :move_to_board, @another_board.id
    end
  end
  
  test "increments Topic#comments_count when a new post is created" do
    assert_difference '@topic.reload.comments_count', 1 do
      @topic.reply(@user, :body => 'body').save
    end
  end

  test "decrements Topic#comments_count when a post is deleted" do
    assert_difference '@topic.reload.comments_count', -1 do
      @topic.comments.first.destroy
    end
  end

  test "does not raise when when a topic's last post is deleted" do
    assert_nothing_raised do
      @topic.comments.each { |comment| comment.destroy }
    end
  end
end

class ForumWithoutBoardsCounterTest < ActiveSupport::TestCase
  def setup
    super
    @forum = Forum.find_by_title 'a forum without boards'
    @topic = @forum.topics.find_by_title 'a topic'
    @user = User.first
  end

  test "increments Forum#topics_count when a new topic is created" do
    assert_difference '@forum.reload.topics_count', 1 do
      @forum.topics.post @user, :title => 'topic', :body => 'body'
    end
  end

  test "decrements Forum#topics_count when a topic is deleted" do
    assert_difference '@forum.reload.topics_count', -1 do
      @topic.destroy
    end
  end

  test "increments Forum#comments_count when a new topic is created" do
    assert_difference '@forum.reload.comments_count', 1 do
      @forum.topics.post @user, :title => 'topic', :body => 'body'
    end
  end

  test "increments Forum#comments_count when a new post is created" do
    assert_difference '@forum.reload.comments_count', 1 do
      @topic.reply(@user, :body => 'body').save
    end
  end

  test "decrements Forum#comments_count when a post is deleted" do
    assert_difference '@forum.reload.comments_count', -1 do
      @topic.comments.last.destroy
    end
  end

  test "decrements Forum#comments_count by topic.comments_count when a topic is deleted" do
    assert_difference '@forum.reload.comments_count', -@topic.comments_count do
      @topic.destroy
    end
  end

  test "increments Topic#comments_count when a new post is created" do
    assert_difference '@topic.reload.comments_count', 1 do
      @topic.reply(@user, :body => 'body').save
    end
  end

  test "decrements Topic#comments_count when a post is deleted" do
    assert_difference '@topic.reload.comments_count', -1 do
      @topic.comments.last.destroy
    end
  end
end