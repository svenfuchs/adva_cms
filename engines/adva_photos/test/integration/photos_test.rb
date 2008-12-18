require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PhotosTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :admin
    factory_scenario  :site_with_an_album
  end
  
  def test_an_admin_views_the_album
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
  end
  
  def test_an_admin_views_the_upload_photo_form_from_empty_album
    # when there is no photos
    Photo.delete_all
    
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
    
    # Go to photo upload
    click_link 'Upload one now'
    
    # the page renders the photo upload form
    assert_template 'admin/photos/new'
  end
  
  def test_an_admin_views_the_upload_photo_form_from_non_empty_album
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
    
    # Go to photo upload
    click_link 'Upload a photo'
    
    # the page renders the photo upload form
    assert_template 'admin/photos/new'
  end
  
  def test_an_admin_views_the_edit_photo_form
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
    
    # Go to photo upload
    click_link @photo.title
    
    # the page renders the photo upload form
    assert_template 'admin/photos/edit'
  end
  
  def test_an_admin_edits_the_photo
    # Go to the new form
    get edit_admin_photo_path(@site, @album, @photo)
    
    # the page renders the photos new form
    assert_template 'admin/photos/edit'
    
    # make sure of that photo count is 1
    assert Photo.all.size == 1
    
    fill_in       'Title', :with => 'edited title'
    click_button  'Update'
    
    # picture is updated
    assert Photo.all.size == 1
    @photo.reload
    assert @photo.title == 'edited title'
  end
  
  def test_an_admin_uploads_a_photo
    # Go to the new form
    get new_admin_photo_path(@site, @album)
    
    # the page renders the photos new form
    assert_template 'admin/photos/new'
    
    # make sure of that photo count is 1
    assert Photo.all.size == 1
    
    fill_in       'Title', :with => 'the rails logo'
    attach_file   'Choose a photo', File.join(Rails.root, 'public', 'images', 'rails.png')
    click_button  'Upload'
    
    # picture is uploaded
    assert Photo.all.size == 2
  end
  
  def test_an_admin_destroy_a_photo
    # Go to album index
    get admin_photos_path(@site, @album)
    
    # the page renders the photos index page
    assert_template 'admin/photos/index'
    
    # make sure of that photo count is 1
    assert Photo.all.size == 1
    
    # Go to photo upload
    click_link 'Delete'
    
    # picture is deleted
    assert Photo.all.size == 0
  end
end