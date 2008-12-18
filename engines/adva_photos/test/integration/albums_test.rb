require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class NewAlbumTest < ActionController::IntegrationTest
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

class ExistingAlbumTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :admin
    factory_scenario  :site_with_an_album
  end
  
  def test_an_admin_views_the_album_settings_page
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
    
    # Go to photo upload
    click_link 'settings_section'
    
    # the page renders the photo upload form
    assert_template 'admin/sections/edit'
  end
end
