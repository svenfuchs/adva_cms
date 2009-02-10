require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class FailGracefullyTest < ActionController::IntegrationTest
  def setup
    # Note to self, login_as deletes all the users, so photo.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :anonymous
    factory_scenario  :site_with_an_album_sets_and_tags
  end
  
  def test_fails_gracefully_when_user_tries_to_sort_photos_by_non_existant_tag
    # Sort photos by non-existant tag
    get '/tags/null'
    
    assert_template 'albums/index'
  end
  
  def test_fails_gracefully_when_user_tries_to_sort_photos_by_non_existant_set
    # Sort photos by non-existant set
    get '/sets/null'
    
    assert_template 'albums/index'
  end
  
  def test_fails_gracefully_when_user_tries_to_find_non_existant_photo
    # Non-existant photo
    get '/photos/666'
    
    assert_redirected_to '/'
  end
end