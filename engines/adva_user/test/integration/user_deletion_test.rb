require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class UserDeletionTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  def setup
    Event::TestLog.clear!
    factory_scenario :site_with_a_section
    @user = Factory :user
  end

  def test_user_deletes_user_account
    # user logs in to the site
    visit '/login'
    fill_in 'email', :with => @user.email
    fill_in 'password', :with => @user.password
    click_button 'Login'

    # TODO
    # there's no user profile page so far
    # visit user_path
    # click_link 'Edit User'
    # click_link 'delete'
    
    # user deletes the own profile
    delete user_path
    
    # user should not be there anymore
    assert_raises ActiveRecord::RecordNotFound do User.find(@user.id) end
    
    # should have triggered a :user_deleted event
    assert_events_triggered :user_deleted
  end
end