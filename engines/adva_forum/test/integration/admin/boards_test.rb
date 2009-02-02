require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class BoardsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  test 'an admin creates a new board' do
    login_as_admin
    visit_forum_backend
    visit_new_board_form
    fill_in_and_submit_the_new_board_form
  end
  
  test 'an admin edits a board' do
    login_as_admin
    visit_forum_backend
    visit_edit_board_form
    fill_in_and_submit_the_edit_board_form
  end
  
  test 'an admin deletes the board' do
    login_as_admin
    visit_forum_backend
    delete_the_board
  end
  
  test 'an admin creates a new board for topics, deletes the only board of forum and visits the forum frontend' do
    login_as_admin
    visit_boardless_forum_backend
    visit_new_board_form
    fill_in_and_submit_the_new_board_form
    
    @board = @forum.boards.first
    
    delete_the_board
    visit_frontend
  end
  
  def visit_forum_backend
    @forum = Forum.find_by_permalink('a-forum-with-boards')
    @board = @forum.boards.find_by_title('a board')
    
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
  end
  
  def visit_frontend
    click_link 'Forum'
    assert_template 'forum/show'
  end
  
  def visit_boardless_forum_backend
    @forum = Forum.find_by_permalink('a-forum-without-boards')
    
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
  end
  
  def visit_new_board_form
    click_link 'Create a new board'
    assert_template 'admin/boards/new'
  end
  
  def visit_edit_board_form
    click_link "board_#{@board.id}_edit"
    assert_template 'admin/boards/edit'
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
  
  def fill_in_and_submit_the_edit_board_form
    fill_in       'Title',       :with => 'Test board update'
    fill_in       'Description', :with => 'Test board description'
    click_button  'Save'
    
    @board.reload
    assert @board.title == 'Test board update'
    assert_template 'admin/boards/index'
  end
  
  def delete_the_board
    board_count = @forum.boards.size
    
    click_link "board_#{@board.id}_delete"
    
    @forum.reload
    assert @forum.boards.size == board_count - 1
    assert_template 'admin/boards/index'
  end
end