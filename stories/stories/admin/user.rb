require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing users", %(
  As an admin
  I want to manage the users registered to a site), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new user account" do
     Given "a site"
       And "the user is logged in as admin"
      When "the user visits the site's user list page"
       And "the user clicks on 'Add user'"
      Then "the page has a user account creation form"
      When "the user fills in the user account creation form with valid values"
       And "the user clicks the 'Create' button"
      Then "a new user account is created"
       And "the user is redirected to a site's user show page"
  end
  
  Scenario "An admin updates a user's profile" do
     Given "a site"
       And "the user is logged in as admin"
       And "another user"
       And "the other user is a member of the site"
      When "the user visits the other user's show page"
       And "the user clicks on 'Edit user'"
      Then "the page has a user account edit form"
      When "the user fills in name with 'an updated name'"
       And "the user clicks the 'Save' button"
      Then "the other user's name is 'an updated name'"
       And "the user is redirected to a site's user show page"
  end
end