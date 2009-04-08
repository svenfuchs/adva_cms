require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class ForumTopicsEdgeCases < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  test 'an admin creates a new board in a forum with existing topics and no boards' do
    login_as_admin
    visit_boards_index
    visit_new_board_form
    fill_in_and_submit_the_new_board_form
    topics_are_now_assigned_to_the_board
  end
  
  test 'an admin deletes the last board should preserve topics' do
    login_as_admin
    visit_boards_index
    visit_new_board_form
    fill_in_and_submit_the_new_board_form
    topics_are_now_assigned_to_the_board
    delete_the_board
    topics_are_now_unassigned_from_the_board
  end
  
  def visit_boards_index
    @forum = Forum.find_by_permalink('a-forum-without-boards')
    @topics = @forum.topics
    
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
  end
  
  def visit_new_board_form
    click_link 'New'
    assert_template 'admin/boards/new'
  end
  
  def fill_in_and_submit_the_new_board_form
    board_count = @forum.boards.size
    
    fill_in       'Title',       :with => 'Test board'
    fill_in       'Description', :with => 'Test board description'
    click_button  'Save'
    
    @forum.reload
    assert @forum.boards.size == board_count + 1
    assert_template 'admin/boards/index'
  end
  
  def delete_the_board
    board = @forum.boards.first
    board_count = @forum.boards.size
    
    click_link "delete_board_#{board.id}"
    
    @forum.reload
    assert @forum.boards.size == board_count - 1
    assert_template 'admin/boards/index'
  end
  
  def topics_are_now_assigned_to_the_board
    @forum.topics.reload
    board = @forum.boards.first
    @topics.each do |topic|
      assert topic.board == board
    end
  end
  
  def topics_are_now_unassigned_from_the_board
    @forum.topics.reload
    board = @forum.boards.first
    @topics.each do |topic|
      assert topic.board != board
    end
  end
end