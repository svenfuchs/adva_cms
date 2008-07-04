require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a blog's categories", %(
  As an admin
  I want to manage my blog's categories
  So I can categorize content), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new blog category" do
     Given "a blog with no categories"
       And "the user is logged in as admin"
      When "the user visits the blog's categories list page"
      Then "the page has an empty list"
      When "the user clicks on 'Create one now'"
      Then "the page has a category creation form"
      When "the user fills in the category creation form with valid values"
       And "the user clicks the Save button"
      Then "a new category is saved" 
       And "the user is redirected the blog categories list page"
       And "the page has a list of blog categories with the new category listed"
  end
  
  Scenario "An admin updates a category" do
     Given "a blog with a category"
       And "the user is logged in as admin"
      When "the user visits the blog category's edit page"
      Then "the page has a category edit form"
      When "the user fills in title with 'an updated title'"
       And "the user clicks the Save button"
      Then "the category's title is: an updated title"
       And "the user is redirected the blog category's edit page"
      When "the user clicks on 'Categories'"
      Then "the user sees the blog categories list page"
  end
end