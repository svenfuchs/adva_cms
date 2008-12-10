require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AnAlbumTest < ActionController::IntegrationTest
  def setup
    factory_scenario  :empty_site
    login_as          :admin
  end
  
  def test_an_admin_creates_a_new_album
    # Go to section create form
    get new_admin_section_path(@site)
    
    assert @site.sections.count == 0
    
    # Admin chooses an album type of section
    choose 'Album'
    
    # Admin writes the title of the album
    fill_in 'Title', :with => 'My first album'
    
    # Admin creates the album
    click_button 'Save'
    
    assert @site.sections.count == 1
  end
end