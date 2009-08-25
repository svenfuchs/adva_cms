require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class UserLoginTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
    end
  
    test "A verified user logs in with valid credentials" do
      visit '/login'

      fill_in 'user_email', :with => 'a-user@example.com'
      fill_in 'user_password', :with => 'a password'
      click_button 'login'

      controller.current_user.should_not be_nil
      controller.current_user.email.should == 'a-user@example.com'
    end
  
    test "A verified user logs in with invalid credentials" do
      visit '/login'
      fill_in 'user_email', :with => 'a-user@example.com'
      fill_in 'user_password', :with => 'a wrong password'
      click_button 'login'

      controller.current_user.should be_nil
      renders_template 'session/new'
    end
      
    test "An unverified user logs in with valid credentials" do
      visit '/login'
      fill_in 'user_email', :with => 'an-unverified-user@example.com'
      fill_in 'user_password', :with => 'a password'
      click_button 'login'

      # FIXME we don't provide any more specific feedback?
      controller.current_user.should be_nil
      renders_template 'session/new'
    end
      
    test "An unverified user logs in with invalid credentials" do
      visit '/login'
      fill_in 'user_email', :with => 'an-unverified-user@example.com'
      fill_in 'user_password', :with => 'a wrong password'
      click_button 'login'

      # FIXME we don't provide any more specific feedback?
      controller.current_user.should be_nil
      renders_template 'session/new'
    end
  end
end