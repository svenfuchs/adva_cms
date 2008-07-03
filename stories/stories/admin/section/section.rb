require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a site's sections", %(
  As an admin
  I want to manage my site's sections
  So I can have the site arranged the way I need), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new Section" do
    Given "a site with no sections"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections"
    Then "the page has an empty list of sections"
    When "the user GETs /admin/sites/1/sections/new"
    Then "the page has a form posting to /admin/sites/1/sections"
    And "the 'safe as draft' checkbox is checked"
    When "the user POSTs to", '/admin/sites/1/sections', :section => valid_section_attributes
    Then "a new section is saved"
    And "the user is redirected to /admin/sites/1/sections/1"
  end
  
  Scenario "An admin updates a section's settings" do
    Given "a site with a section"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections/1"
    Then "the page has a form putting to /admin/sites/1/sections/1"
    When "the user PUTs to", '/admin/sites/1/sections/1', :section => valid_section_attributes(:title => 'updated title')
    Then "the section's title is 'updated title'"
  end
end