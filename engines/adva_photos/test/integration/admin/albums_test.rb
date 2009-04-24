require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class AlbumsTest < ActionController::IntegrationTest
  def setup
    super
    @site   = use_site! 'site with pages'
    @album  = Album.find_by_permalink('an-album') 
  end
  
  test 'an admin creates a new album' do
    login_as_admin
    visit_section_new_form
    fill_in_and_submit_section_new_form
  end
  
  test 'an admin views the album settings page' do
    login_as_admin
    visit_backend_album_page
    click_link_within '#main_menu', 'settings'
    display_section_settings_edit_form
  end
  
  def visit_section_new_form
    get new_admin_section_path(@site)
    assert_template 'admin/sections/new'
  end
  
  def visit_backend_album_page
    get admin_photos_path(@site, @album)
    assert_template 'admin/photos/index'
  end
  
  def fill_in_and_submit_section_new_form
    section_count = @site.sections.size
    
    fill_in 'Title', :with => 'My first album'
    select 'Album'
    click_button 'Save'
    
    @site.reload
    assert @site.sections.size == section_count + 1
    assert @site.sections.last.is_a?(Album)
  end
  
  def display_section_settings_edit_form
    assert_template 'admin/sections/edit'
  end
end
