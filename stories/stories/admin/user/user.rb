require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing users", %(
  As an admin
  I want to manage the users registered to a site), :steps_for => steps(:all), :type => RailsStory do
    
  Scenario "An admin updates his own profile" do
    Given "a site"
    And "the user is logged in as admin"
  end
  
  Scenario "An admin creates a new user account" do
    Given "a site"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/users"
    Then "the page has a list of users with one entry"
    When "the user GETs /admin/sites/1/users/new"
    Then "the page has a form posting to /admin/sites/1/users"
    When "the user POSTs to", '/admin/sites/1/users', :theme => valid_user_attributes
    Then "a new user is saved"
    And "the user is redirected to /admin/sites/1/users/2"
    When "the user follows the redirect"
    Then "the page shows the user name"
  end
  
  Scenario "An admin updates another user's profile" do
    Given "a site"
    And "the user is logged in as admin"
    And "another user"
    When "the user GETs /admin/sites/1/users/2"
    Then "the page has a form putting to /admin/sites/1/users/2"
    When "the user PUTs to", '/admin/sites/1/users/2', :section => valid_site_attributes(:author => 'updated name')
    Then "the user's name is 'updated name'"
  end
end