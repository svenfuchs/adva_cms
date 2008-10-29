require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AccountSignupTest < ActionController::IntegrationTest
  
  def setup
    Factory :free_account
    Factory :small_account
  end
  
  def test_new_user_free_account
    
    # go to account plans page
    visits "account/plans"

    # select the free plan
    clicks_link "free"

    # Make sure the user doesn't exist yet    
    assert_nil User.find_by_email('john.doe@example.com')
    
    # fill out account stuff
    fills_in "domain name", :with => 'test-account'
    chooses 'free'
     
    # fill out user stuff
    fills_in "first name", :with => 'John'
    fills_in "last name", :with => 'Doe'
    fills_in "email", :with => 'john.doe@example.com'
    fills_in "password", :with => 'password123'
    clicks_button "Sign Up"
    
    # the user should be there and not be verified
    user = User.find_by_email('john.doe@example.com')
    assert_not_nil user

    assert user.authenticate('password123')
    
    # should render the dashboard template
    assert_template 'dashboard/index'
    
    # should have sent an email notification
    assert ActionMailer::Base.deliveries.any?, 'ActionMailer should have sent a notification'
    assert ActionMailer::Base.deliveries.first.to.include?(user.email)
    assert ActionMailer::Base.deliveries.first.body =~ /myname/
    assert ActionMailer::Base.deliveries.first.body =~ /test\-account/
    assert ActionMailer::Base.deliveries.first.body =~ /password123/
  
    # should have created a site
    site = Site.find_by_host('test-account.advabest.com') # have to change this to the test domain
    assert_not_nil site
    
    # should have created an account. free account hostname == site hostname
    account = Account.find_by_host('test-account.advabest.com')
    assert_not_nil account
  end

  # test new user, paid account
  # test existing user, free account
  # test existing user, paid account
  # test new user, free account, email taken
  # test new user, free account, email invalid
  # test new user, free account, account name taken
  
end
