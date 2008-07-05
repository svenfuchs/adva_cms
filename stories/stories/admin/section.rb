require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a site's sections", %(
  As an admin
  I want to manage my site's sections
  So I can have the site arranged the way I need), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new Section" do
     Given "a site with no sections"
       And "the user is logged in as admin"
      When "the user visits the new section page"
      Then "the page has a section creation form"
      When "the user fills in the section creation form with valid values"
       And "the user clicks the 'Save' button"
      Then "a new Section was created with the title 'a new section title'"
       And "the user is redirected the section's show page"
  end
  
  Scenario "An admin updates a Section's settings" do
     Given "a site with a Section"
       And "the user is logged in as admin"
      When "the user visits the section's show page"
      Then "the page has a section edit form"
      When "the user fills in title with 'an updated title'"
       And "the user clicks the 'Save' button"
      Then "the Section's title is: an updated title"
       And "the user is redirected the section's show page"
  end
end