require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class PhotosTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with pages'
    @album = Album.find_by_permalink('an-album')
    @photo = @album.photos.first
  end

  test 'an admin edits the photo' do
    login_as_admin
    visit_album_backend
    click_link @photo.title
    display_edit_photo_form
    fill_in_and_submit_edit_form
  end

  test 'an admin creates a new photo' do
    login_as_admin
    visit_album_backend
    click_link 'New'
    display_new_photo_form
    fill_in_and_submit_new_form
  end

  test 'an admin destroy the photo' do
    login_as_admin
    visit_album_backend
    click_link_delete_photo
  end

  def visit_album_backend
    get admin_photos_path(@site, @album)
    assert_template 'admin/photos/index'
  end

  def display_new_photo_form
    assert_template 'admin/photos/new'
  end

  def display_edit_photo_form
    assert_template 'admin/photos/edit'
  end

  def fill_in_and_submit_edit_form
    fill_in       'Title', :with => 'edited title'
    click_button  'Save'

    @photo.reload
    assert @photo.title == 'edited title'
  end

  def fill_in_and_submit_new_form
    photos_count = @album.photos.size

    fill_in       'Title', :with => 'the rails logo'
    attach_file   'Choose a photo', File.expand_path(File.dirname(__FILE__) + '/../../fixtures/rails.png')
    click_button  'Upload'

    @album.reload
    assert @album.photos.size == photos_count + 1
  end

  def click_link_delete_photo
    photos_count = @album.photos.size

    click_link "delete_photo_#{@photo.id}"

    @album.reload
    assert @album.photos.size == photos_count - 1
  end
end