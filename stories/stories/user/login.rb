require File.expand_path(File.dirname(__FILE__) + "/../../helper")

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