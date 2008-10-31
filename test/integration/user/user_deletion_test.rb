require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

def assert_events_triggered(*types)
  actual = types.select{|type| Event::TestLog.was_triggered?(type) }
  assert_equal actual.size, types.size, "expected events #{types.inspect} to be triggered but only found #{actual.inspect}"
end

class UserDeletionTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  def setup
    Site.delete_all
    Section.delete_all
    User.delete_all

    Event::TestLog.clear!
    Factory :site_with_section
    @user = Factory :user
  end
  
  def test_user_deletes_user_account
    # user logs in to the site
    visits '/login'
    fills_in 'email', :with => @user.email
    fills_in 'password', :with => @user.password
    clicks_button 'Login'

    # TODO
    # there's no user profile page so far
    # visits user_path
    # clicks_link 'Edit User'
    # clicks_link 'delete'
    
    # user deletes the own profile
    delete user_path
    
    # user should not be there anymore
    assert_raises ActiveRecord::RecordNotFound do User.find(@user.id) end
    
    # should have triggered a :user_deleted event
    assert_events_triggered :user_deleted
  end
end