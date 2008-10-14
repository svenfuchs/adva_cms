require 'test_helper'

class UserRegistrationTest < ActionController::IntegrationTest
  
  def test_user_registers
    setup_site
    
    # go to user registration page
    visits "account/new"
    assert_response :success

    # fill in the form
    fills_in "name", :with => 'name'
    fills_in "email", :with => 'email@test.com'
    fills_in "login", :with => 'login'
    fills_in "password", :with => 'password'
    fills_in "password confirmation", :with => 'password'
    clicks_button "Register"
    
    # the user should be there and not verified
    user = User.find_by_name('name')
    assert_not_nil user
    assert !user.verified?
    
    # should render the account/verification_sent template
    assert_template 'account/verification_sent'
    
    # should have sent an email notification
    assert ActionMailer::Base.deliveries.any?, 'ActionMailer should have sent a notification'
    assert ActionMailer::Base.deliveries.first.to.include?(user.email)
  end
  
  protected
  
    def setup_site
      @site = Site.new :host => 'www.example.com', :title => 'site 1 title', :name => 'site 1'
      @home = @site.sections.build :title => 'Home', :type => 'Section'
      @site.sections << @home
      @site.save
    end
end