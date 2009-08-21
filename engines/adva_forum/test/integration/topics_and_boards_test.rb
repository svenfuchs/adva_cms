require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicsAndBoardsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  # Without boards
  
  test 'an admin creates an initial topic' do
    login_as_admin
    visit_a_boardless_and_topicless_board
    click_link 'Post one now'
    fill_in_and_submit_a_new_topic_form
  end
  
  # With boards
  
  test 'an admin creates a new topic' do
    login_as_admin
    visit_a_forum_with_boards
    visit_a_board_with_topic
    click_link 'New topic'
    fill_in_and_submit_a_new_topic_form
  end
  
  # Board specific
  
  test 'an admin moves an existing topic to another board' do
    login_as_admin
    visit_a_forum_with_boards
    visit_a_board_with_topic
    click_link @topic.title
    move_topic_to_another_board
  end
  
  def visit_a_forum_with_boards
    @forum = Forum.find_by_permalink 'a-forum-with-boards'
    
    get '/a-forum-with-boards'
    renders_template "forum/show"
  end
  
  def visit_a_boardless_and_topicless_board
    @forum = Forum.find_by_permalink 'a-forum-without-boards'
    @forum.topics.delete_all
    
    get '/a-forum-without-boards'
    renders_template "forum/show"
  end
    
  def visit_a_board_with_topic
    @board = @forum.boards.find_by_title('a board')
    @topic = @board.topics.find_by_permalink('a-board-topic')
    
    click_link @board.title
    renders_template "forum/show"
  end
  
  def fill_in_and_submit_a_new_topic_form
    raise "@forum is not set!" unless @forum
    
    forum_topics = @forum.topics.size
    
    assert_template 'topics/new'
    fill_in       'Title',       :with => 'Test topic'
    fill_in       'Body',        :with => 'Test topic description'
    click_button  'Post topic'
    
    @forum.reload
    assert_equal forum_topics + 1, @forum.topics.size
    assert_template 'topics/show'
  end
  
  def move_topic_to_another_board
    assert @topic.initial_post.board == @board
    another_board = @forum.boards.find_by_title('another board')
    
    click_link 'Edit'
    assert_template 'topics/edit'
    
    select        another_board.title
    click_button  'Save'
    @topic.reload; @topic.initial_post.reload
    
    assert @topic.board == another_board
    assert @topic.initial_post.board == another_board
    assert_template 'topics/show'
  end
end