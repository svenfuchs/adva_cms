require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AnonymousUserViewsPhotosTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :anonymous
    factory_scenario  :site_with_an_album_sets_and_tags
  end
  
  def test_anonymous_user_views_the_album
    # Goto album page
    get "/albums/#{@album.id}"
    
    # page renders albums index
    assert_template 'albums/index'
    
    # user sees all the photos
    # except the unpublished photo ...
    assert_select "div#photo_#{@photo.id}", false
    
    # the summer photo ...
    assert_select "div#photo_#{@summer_photo.id}" do
      assert_select "a[href='/photos/#{@summer_photo.id}']"
    end
    
    # and the winter photo ...
    assert_select "div#photo_#{@winter_photo.id}" do
      assert_select "a[href='/photos/#{@winter_photo.id}']"
    end
  end
  
  def test_anonymous_user_views_a_summer_set
    # Goto album page
    get "/albums/#{@album.id}"
    
    # page renders albums index
    assert_template 'albums/index'
    
    click_link @summer_set.title
    
    # page renders albums index
    assert_template 'albums/index'
    
    # user sees the summer photo ...
    assert_select "div#photo_#{@summer_photo.id}" do
      assert_select "a[href='/photos/#{@summer_photo.id}']"
    end
    
    # but not unpublished photo ...
    assert_select "div#photo_#{@photo.id}", false
    
    # or winter photo
    assert_select "div#photo_#{@winter_photo.id}", false
  end
  
  def test_anonymous_user_views_a_seasons_tag
    # Goto album page
    get "/albums/#{@album.id}"
    
    # page renders albums index
    assert_template 'albums/index'
    
    click_link @season_tag.name
    
    # page renders albums index
    assert_template 'albums/index'
    
    # user sees the summer photo ...
    assert_select "div#photo_#{@summer_photo.id}" do
      assert_select "a[href='/photos/#{@summer_photo.id}']"
    end
    
    # and the winter photo ...
    assert_select "div#photo_#{@winter_photo.id}" do
      assert_select "a[href='/photos/#{@winter_photo.id}']"
    end
    
    # but not unpublished photo ...
    assert_select "div#photo_#{@photo.id}", false
  end
  
  def test_anonymous_user_views_a_empty_tag
    # Goto album page
    get "/tags/Empty"
    
    # page renders albums index
    assert_template 'albums/index'
    
    # user does not see any photos
    # does not see the unpublished photo ...
    assert_select "div#photo_#{@photo.id}", false
    
    # does not see the summer photo ...
    assert_select "div#photo_#{@summer_photo.id}", false
    
    # does not see the winter photo ...
    assert_select "div#photo_#{@winter_photo.id}", false
  end
end