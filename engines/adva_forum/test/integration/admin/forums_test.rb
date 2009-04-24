require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class ForumsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  test 'an admin creates a new forum' do
    login_as_admin
    visit_new_section_form
    fill_in_and_submit_new_section_form
  end
  
  test 'an admin edits an existing forum' do
    login_as_admin
    visit_forum_backend
    visit_edit_section_form
    fill_in_and_submit_edit_section_form
  end
  
  test 'an admin deletes an existing forum' do
    login_as_admin
    visit_forum_backend
    visit_edit_section_form
    delete_the_section
  end
  
  def visit_forum_backend
    @forum = Forum.find_by_permalink('a-forum-with-boards')
    @board = @forum.boards.find_by_title('a board')
    
    get admin_boards_path(@site, @forum)
    assert_template 'admin/boards/index'
  end
  
  def visit_new_section_form
    get new_admin_section_path(@site)
    assert_template 'sections/new'
  end
  
  def visit_edit_section_form
    click_link_within '#main_menu', 'Settings'
    assert_template 'sections/edit'
  end
  
  def fill_in_and_submit_new_section_form
    sections_count = @site.sections.count
    
    select 'Forum'
    fill_in 'Title', :with => 'test forum'
    click_button 'Save'
    
    @site.reload
    assert @site.sections.count == sections_count + 1
    assert @site.sections.last.is_a?(Forum)
    assert_template 'admin/topics/index'
  end
  
  def fill_in_and_submit_edit_section_form
    assert @forum.title != 'Changed forum title'
    
    fill_in 'Title', :with => 'Changed forum title'
    click_button 'Save'
    
    @forum.reload
    assert @forum.title == 'Changed forum title'
    assert_template 'admin/sections/edit'
  end
  
  def delete_the_section
    section_count = @site.sections.size
    
    click_link 'Delete'
    
    assert @site.sections.size == section_count - 1
    assert_template 'admin/sections/new'
  end
end
