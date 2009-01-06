require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class NewForumTest < ActionController::IntegrationTest
  def setup
    factory_scenario  :empty_site
    login_as          :admin
  end
  
  def test_an_admin_creates_a_new_forum
    # Go to section create form
    get new_admin_section_path(@site)
    
    assert @site.sections.count == 0
    
    # Admin chooses an forum section
    choose 'Forum'
    
    # Admin writes the title of the section
    fill_in 'Title', :with => 'My first forum'
    
    # Admin creates the section
    click_button 'Save'
    
    assert @site.sections.count == 1
            
    # Page renders the forum content index
    assert_template 'admin/boards/index'
  end
end

class AnExistingForum < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
  end
  
  def test_an_admin_edits_an_existing_forum
    # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link settings
    click_link 'settings_section'
    
    assert @forum.title != 'Changed forum title'
    
    # Admin changess the title of the section
    fill_in 'Title', :with => 'Changed forum title'
    
    # Admin creates the section
    click_button 'Save'
    
    @forum.reload
    assert @forum.title == 'Changed forum title'
    
    # Page renders section edit form
    assert_template 'admin/sections/edit'
  end
  
  def test_an_admin_deletes_an_existing_forum
    # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link settings
    click_link 'settings_section'
    
    assert @site.sections.count == 1
    
    # Admin clicks link settings
    click_link 'Delete this section'
    
    assert @site.sections.count == 0
    
    # Page renders section new form
    assert_template 'admin/sections/new'
  end
  
  def test_an_admin_goes_to_manage_forum_on_frontend
    # Go to section
    get admin_boards_path(@site, @forum)
    
    # Admin clicks link settings
    click_link 'Forum'
    
    assert_template '/'
  end
end
