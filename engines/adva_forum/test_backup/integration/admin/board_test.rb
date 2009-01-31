require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class AnExistingForumWithBoards < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
    @board  = Factory :board, :site => @site, :section => @forum
  end
  
  def test_an_admin_creates_a_new_board
     # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link create a new board
    click_link 'Create a new board'
    
    assert Board.count == 1
    
    assert_template 'admin/boards/new'
    
    fill_in       'Title',       :with => 'Test board'
    fill_in       'Description', :with => 'Test board description'
    click_button  'Save'
    
    assert Board.count == 2
    
    assert_template 'admin/boards/index'
  end
  
  def test_an_admin_edits_a_board
    assert Board.count  == 1
    assert @board.title != 'Test board update'
    
     # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link to edit board
    click_link 'Edit'
    
    assert_template 'admin/boards/edit'
    
    fill_in       'Title',       :with => 'Test board update'
    fill_in       'Description', :with => 'Test board description'
    click_button  'Save'
    
    @board.reload
    assert Board.count  == 1
    assert @board.title == 'Test board update'
    
    assert_template 'admin/boards/index'
  end
  
  def test_an_admin_deletes_the_board
    assert Board.count  == 1
    
     # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link to delete a board
    click_link 'Delete'
    
    assert Board.count  == 0
    
    assert_template 'admin/boards/index'
  end
end