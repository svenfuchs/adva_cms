require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

def assert_events_triggered(*types)
  actual = types.select{|type| Event::TestLog.was_triggered?(type) }
  assert_equal actual.size, types.size, "expected events #{types.inspect} to be triggered but only found #{actual.inspect}"
end

class UserRegistrationTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers
  
  def setup
    ActionMailer::Base.deliveries = []
    Event::TestLog.clear!
    factory_scenario :site_with_a_section
  end

  def test_user_registers_and_verifies_the_email
    # go to user registration page
    visit "user/new"

    # fill in the form
    fill_in "first name", :with => 'John'
    fill_in "last name", :with => 'Doe'
    fill_in "email", :with => 'email@test.com'
    fill_in "password", :with => 'password'
    click_button "Register"

    # the user should be there and not verified
    user = User.find_by_email('email@test.com')
    assert_not_nil user
    assert !user.verified?, 'user should not be verified'

    # should render the account/verification_sent template
    assert_template 'user/verification_sent'

    # should have triggered a :user_registered event
    assert_events_triggered :user_created, :user_registered

    # should have sent an email notification
    assert ActionMailer::Base.deliveries.any?, 'ActionMailer should have sent a notification'
    email = ActionMailer::Base.deliveries.first
    assert email.to.include?(user.email)

    # extract the verification url from the email
    # http://www.example.com/user/verify?token=1%3Bbd69ea84ed49b61623da2c4d74de2936eb0b0229
    email.body =~ /^(http:.*)$/
    url = $1
    assert_not_nil url, 'email should contain a url'

    # and visit it
    get url

    # should have triggered a :user_verified event
    assert_events_triggered :user_updated, :user_verified

    # user should be verified
    user.reload
    assert user.verified?, 'user should be verified'

    # should be redirected to /
    assert_redirected_to 'admin/sites', 'user should be redirected to admin/sites'

    # should see a flash notice
    assert_not_nil flash_cookie["notice"], 'flash cookie should have a notice'
  end

  test "there is alias 'signup' and goes to user/new page" do
    # go to user registration page
    visit "signup"
    assert_template "user/new"
  end
end
