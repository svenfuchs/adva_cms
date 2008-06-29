require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Registration", %(
  As a visitor
  I can register
  So I can login to the system), :steps_for => steps(:default, :user), :type => RailsStory do
  
  Scenario "The registration page" do
    When "the user GETs /account/new"
    Then "the page has a form posting to /account"
  end
  
  Scenario "A user registers" do
    When "a user registers"
    Then "a new, unverified account is saved"
    And "a verification email is sent to the user's email address"
  end
  
  Scenario "A user registers" do
    When "a user verifies his account (using the link from the verification email)"
    Then "the user account is verfied"
  end
end

Story "Log in", %(
  As a user
  I can login
  So I can by identified by the system), :steps_for => steps(:default, :user), :type => RailsStory do

  Scenario "The login page" do
    When "the user GETs /login"
    Then "the page has a form posting to /session"
  end

  Scenario "A verified user logs in with valid credentials" do
    Given "a user"
    And "the user is verified"
    When "the user logs in with $credentials", {:login => 'login', :password => 'password'}
    Then "the system authenticates the user"
  end

  Scenario "A verified user logs in with wrong credentials" do
    Given "a user"
    And "the user is verified"
    When "the user logs in with $credentials", {:login => 'wrong', :password => 'wrong'}
    Then "the system does not authenticate the user"
    And "the session/new template is rendered"
  end

  Scenario "A not verified user logs in with valid credentials" do
    Given "a user"
    And "the user is not verified"
    When "the user logs in with $credentials", {:login => 'login', :password => 'password'}
    Then "the system does not authenticate the user"
    And "the session/new template is rendered"
  end

  Scenario "A not verified user logs in with invalid credentials" do
    Given "a user"
    And "the user is not verified"
    When "the user logs in with $credentials", {:login => 'wrong', :password => 'wrong'}
    Then "the system does not authenticate the user"
    Then "the session/new template is rendered"
  end
end