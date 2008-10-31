require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class AccountEditTest < ActionController::IntegrationTest
  
  def setup
    Factory :free_account
    @small = Factory :small_account
    Factory :user
  end
  
  def test_change_account_name
    assert_equal 'johndoe', @small.name
     
    # go to account plans page
    page = visits "account/signup"
    
    # change account name
    fills_in "account name", :with => 'My Awesome Account'

    # submit form
    clicks_button "Save"
    
    # should have changed the account name
    assert_equal 'My Awesome Account', @small.name
  end
  
  def test_sidebar_account_listing
    
  end
  
end
