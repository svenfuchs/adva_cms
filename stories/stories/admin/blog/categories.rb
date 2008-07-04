require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing a blog's categories", %(
  As an admin
  I want to manage my blog's categories
  So I can categorize content), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new blog category" do
    Given "a blog"
      And "the user is logged in as admin"
      And "no blog category"
    When "the user visits the blog's categories list page"
    Then "the page has an empty list of blog categories"
    When "the user clicks on 'Create one now'"
    Then "the page has a category creation form"
    When "the user fills in the category creation form with valid values"
     And "the user clicks the Save button"
    Then "the user is redirected the blog's categories list page"
     And "the page has a list of blog categories with the new category listed"
     
    # Then "a new category is saved"
    # And "the user is redirected to /admin/sites/1/blogs/1/categories/a-category"
  end
  
  # Scenario "An admin updates a category" do
  #   Given "a site with a blog"
  #   And "a category"
  #   And "the user is logged in as admin"
  #   When "the user GETs /admin/sites/1/blogs/1/categories/1/edit"
  #   Then "the page has a form putting to /admin/sites/1/blogs/1/categories/1"
  #   When "the user PUTs to", '/admin/sites/1/blogs/1/categories/1', :blog => valid_category_attributes(:title => 'updated title')
  #   Then "the category's title is 'updated title'"
  # end
end