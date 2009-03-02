class Test::Unit::TestCase
  share :a_forum_with_boards do
    before do
      @section        = Forum.find_by_permalink 'a-forum-with-boards'
      @site           = @section.site
      @board          = @section.boards.find_by_title 'a board'
      @another_board  = @section.boards.find_by_title 'another board'
      set_request_host!
    end
  end
  
  share :a_board_topic do
    before do
      @board_topic = @board.topics.find_by_permalink('a-board-topic')
    end
  end
  
  share :a_topicless_board do
    before do
      @topicless_board = @section.boards.find_by_title 'a topicless board'
    end
  end
  
  share :a_forum_without_boards do
    before do
      @section  = Forum.find_by_permalink 'a-forum-without-boards'
      @site     = @section.site
      set_request_host!
    end
  end
  
  share :a_topic_with_reply do
    before do
      @topic = @section.topics.find_by_permalink 'a-topic'
      @reply = @topic.posts.find_by_body 'a reply'
    end
  end
  
  share :without_topics do
    before do
      @section.topics.delete_all
    end
  end
end