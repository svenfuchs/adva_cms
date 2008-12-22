require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class NewSetTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :admin
    factory_scenario  :site_with_an_album
  end
  
  def test_an_admin_visits_the_sets_page
    # Go to section create form
    get admin_photos_path(@site, @album)
    
    # Go to sets
    click_link 'Sets'
    
    # The page shows sets index page
    assert_template 'admin/sets/index'
  end
  
  def test_an_admin_visits_the_new_set_form
    # Go to section create form
    get admin_sets_path(@site, @album)
    
    # Go to set create form
    click_link 'Create one now'
    
    # The page shows sets create form
    assert_template 'admin/sets/new'
  end
  
  def test_an_admin_creates_a_new_set
    # Go to section create form
    get new_admin_set_path(@site, @album)
    
    # The page shows sets create form
    assert_template 'admin/sets/new'
    
    # There are no sets
    assert @album.sets.empty?
    
    fill_in       :title, :with => 'Winter'
    click_button  'Save'
    
    # New set was created
    @album.reload
    assert @album.sets.size == 1
    assert @album.sets.first.title == 'Winter'
  end
end

class AnExistingSetTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :admin
    factory_scenario  :site_with_an_album
    @set = Factory :set, :section => @album
  end
  
  def test_an_admin_visits_the_edit_set_form
    # Go to section create form
    get admin_sets_path(@site, @album)
    
    # Go to set edit form
    click_link @set.title
    
    # The page shows sets create form
    assert_template 'admin/sets/edit'
  end
  
  def test_an_admin_creates_a_new_set
    # Go to section edit form
    get edit_admin_set_path(@site, @album, @set)
    
    # The page shows sets edit form
    assert_template 'admin/sets/edit'
    
    # Check set count
    assert @album.sets.size == 1
    
    fill_in       :title, :with => 'Winter Edit'
    click_button  'Save'
    
    # Set was updated
    @album.reload
    assert @album.sets.size == 1
    assert @album.sets.first.title == 'Winter Edit'
  end
  
  def test_an_admin_destroy_the_set
    # Go to set index
    get admin_sets_path(@site, @album)
    
    # Check set count
    assert @album.sets.size == 1
    
    # Remove the set
    click_link 'Delete'
    
    # Set was updated
    @album.reload
    assert @album.sets.empty?
  end
  
  def test_an_admin_assigns_a_photo_to_the_set
    # Go to photo edit form
    get edit_admin_photo_path(@site, @album, @photo)
    
    # The page shows sets edit form
    assert_template 'admin/photos/edit'
    
    # Check set count
    assert @album.sets.size == 1
    
    check         @set.title
    click_button  'Update'
    
    # Set was updated
    @album.reload
    assert @album.sets.size == 1
    assert @photo.sets == [@set]
  end
  
  def test_an_admin_unassigns_a_photo_from_the_set
    # Given a photo is assigned to a set
    @photo.sets << @set
    @photo.reload
    assert @photo.sets == [@set]
    
    # User goes to a photo edit form
    get edit_admin_photo_path(@site, @album, @photo)
    
    # The page shows the photo edit form
    assert_template 'admin/photos/edit'
    
    # Album set count should be 1
    assert @photo.sets.size == 1
    
    # An user unassigns the photo
    uncheck         @set.title
    click_button  'Update'
    
    # And the set is removed from photo
    @photo.reload
    assert @photo.sets == []
  end
end