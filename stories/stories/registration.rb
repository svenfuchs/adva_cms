require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Registration", %(
  As a visitor
  I can register
  So I can login to the system), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "The registration page" do
    When "the user GETs /account/new"
    Then "the page has a form posting to /account"
  end
  
  Scenario "A user registers and verifies his account" do
    Given "no user exists"
    When "the user POSTs to", '/account', :user => valid_user_attributes
    Then "a user exists"
    And "the user is not verified"
    And "a verification email is sent to the user's email address"
  end
  
  Scenario "A user registers and verifies his account" do
    Given "an unverified user"
    When "the user verifies his account"
    Then "the user is verified"
  end
end
