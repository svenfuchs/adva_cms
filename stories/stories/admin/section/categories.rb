require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a section's categories", %(
  As an admin
  I want to manage my section's categories
  So I can categorize content), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new category" do
    Given "a site with a section"
    And "the user is logged in as admin"
    And "no category"
    When "the user GETs /admin/sites/1/sections/1/categories"
    Then "the page has an empty list of categories"
    When "the user GETs /admin/sites/1/sections/1/categories/new"
    Then "the page has a form posting to /admin/sites/1/sections/1/categories"
    When "the user POSTs to", '/admin/sites/1/sections/1/categories', :category => valid_category_attributes
    Then "a new category is saved"
    And "the user is redirected to /admin/sites/1/sections/1/categories/1"
  end
  
  Scenario "An admin updates a category" do
    Given "a site with a section"
    And "a category"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections/1/categories/1/edit"
    Then "the page has a form putting to /admin/sites/1/sections/1/categories/1"
    When "the user PUTs to", '/admin/sites/1/sections/1/categories/1', :section => valid_category_attributes(:title => 'updated title')
    Then "the category's title is 'updated title'"
  end
end