require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class ForumTopicsSpecialCases < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
    @board  = Factory :board, :site => @site, :section => @forum
    @topic          = @forum.topics.post(@user, Factory.attributes_for(:topic, :section => @forum))
    @another_topic  = @forum.topics.post(@user, Factory.attributes_for(:topic, :section => @forum))
    @topic.save
    @another_topic.save
  end
  
  def test_an_admin_creates_a_new_board_when_there_are_topics_without_a_board
    assert @topic.board == nil
    assert @another_topic.board == nil
    
     # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link create a new board
    click_link 'Create a new board'
    
    assert_template 'admin/boards/new'
    
    fill_in       'Title',       :with => 'Test board'
    fill_in       'Description', :with => 'Test board description'
    click_button  'Save'
    
    @topic.reload; @another_topic.reload
    assert @topic.board         == Board.last
    assert @another_topic.board == Board.last
    
    assert_template 'admin/boards/index'
  end
  
  def test_an_admin_deletes_the_last_board_should_preserve_topics
    @board.topics << @topic; @board.topics << @another_topic
    assert @topic.board         == @board
    assert @another_topic.board == @board
    assert Board.count          == 1
    
     # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link delete a board
    click_link 'board_delete'
    
    assert Board.count          == 0
    @topic.reload; @another_topic.reload
    assert @topic.board         == nil
    assert @another_topic.board == nil
    
    assert_template 'admin/boards/index'
  end
end