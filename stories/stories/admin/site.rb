require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing sites", %(
  As an admin
  I want to manage my sites
  So I can add, update and delete sites), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new site" do
     Given "a site"
       And "the user is logged in as superuser"
      When "the user visits the sites list page"
      When "the user clicks on 'New'"
      Then "the page has a site creation form"
      When "the user fills in the site creation form with valid values"
       And "the user clicks the 'Create' button"
      Then "a new Site is created"
       And "the user is redirected the site's show page"
  end
  
  Scenario "An admin updates a site's settings" do
     Given "a site"
       And "the user is logged in as admin"
      When "the user visits the site's edit page"
      Then "the page has a site edit form"
      When "the user fills in website title with 'an updated title'"
       And "the user clicks the 'Save' button"
      Then "the site's title is: an updated title"
       And "the user is redirected the site's edit page"
  end
end