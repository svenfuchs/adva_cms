require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a site's sections", %(
  As an admin
  I want to manage my site's sections
  So I can have the site arranged the way I need), :steps_for => steps(:all), :type => RailsStory do
  
  # Scenario "An admin updates a section's settings" do
  #   Given "a site with a section"
  #   And "the user is logged in as admin"
  #   When "the user GETs /admin/sites/1/sections/1"
  #   Then "the page has a form putting to /admin/sites/1/sections/1"
  #   When "the user PUTs to", '/admin/sites/1/sections/1', :section => valid_section_attributes(:title => 'updated title')
  #   Then "the section's title is 'updated title'"
  # end
  
  Scenario "An admin creates a new Section" do
     Given "a site with no sections"
       And "the user is logged in as admin"
      When "the user visits the new section page"
      Then "the page has a section creation form"
      When "the user fills in the section creation form with valid values"
       And "the user clicks the Save button"
      Then "a new Section is saved"
       And "the user is redirected the sections show page"
       And "the page has a section edit form"
  end
  
  # Scenario "An admin updates a category" do
  #    Given "a blog with a category"
  #      And "the user is logged in as admin"
  #     When "the user visits the blog category's edit page"
  #     Then "the page has a category edit form"
  #     When "the user fills in title with 'an updated title'"
  #      And "the user clicks the Save button"
  #     Then "the category's title is: an updated title"
  #      And "the user is redirected the blog category's edit page"
  #     When "the user clicks on 'Categories'"
  #     Then "the user sees the blog categories list page"
  #      And "the page has a list of blog categories with the new category listed"
  # end
end