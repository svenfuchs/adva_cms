require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class NewTopicWithoutBoards < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
  end
  
  def test_an_admin_goest_to_new_topic_form
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
    
    click_link 'Create a new Topic'
    assert_template 'topics/new'
  end
  
  def test_an_admin_goest_to_new_topic_form_and_creates_a_topic
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
    
    click_link 'Create a new Topic'
    assert_template 'topics/new'
    
    assert Topic.count == 0
    
    fill_in :title, :with => 'new topic title'
    fill_in :body,  :with => 'new topic body'
    click_button 'Post Topic'
    
    assert_template 'topics/show'
    assert Topic.count == 1
  end
end

class NewTopicWithBoards < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
    @board  = Factory :board, :site => @site, :section => @forum
  end
  
  def test_an_admin_goest_to_new_topic_form
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
    
    click_link 'Create a new Topic'
    assert_template 'topics/new'
  end
  
  def test_an_admin_goest_to_new_topic_form_and_creates_a_topic
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
    
    click_link 'Create a new Topic'
    assert_template 'topics/new'
    
    assert Topic.count == 0
    
    fill_in :title, :with => 'new topic title'
    fill_in :body,  :with => 'new topic body'
    click_button 'Post Topic'
    
    assert_template 'topics/show'
    assert Topic.count == 1
  end
  
  def test_an_admin_creates_a_new_topic_deletes_the_board_and_goes_to_forum_index
    # To make sure topic posts do not disappear
    # Create the topic
    get admin_boards_path(@site, @forum)
    click_link 'Create a new Topic'
    fill_in :title, :with => 'new topic title'
    fill_in :body,  :with => 'new topic body'
    click_button 'Post Topic'
    assert @forum.topics.first.last_comment != nil
    assert_template 'topics/show'
    
    # Delete the board
    get admin_boards_path(@site, @forum)
    click_link 'board_delete'
    assert @forum.topics.first.last_comment != nil
    assert_template 'admin/boards/index'
    
    # Go to forum index
    click_link 'Forum'
    assert_template 'forum/show'
  end
end