require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Publishing a blog article", %(
  As an admin
  I want to write blog articles in the admin area
  So they get published in the frontend), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin writes a blog article" do
    Given "a blog has no articles"
      And "the user is logged in as admin"
    When "the user visits the blog page"
    Then "the page has an empty list"
    When "the user clicks on 'Create one now'"
    Then "the page has a article creation form"
      And "the 'save as draft' checkbox is checked by default"
    When "the user fills in the article creation form with valid values"
      And "the user clicks the 'Save article' button"
    Then "the user is rendered to the blog's articles edit page"
      And "a new article is saved"
  end
end

Story "Deleting a blog article", %(
  As an admin
  I want to delete a blog article in the admin area
  So that unnecessary article does not show anymore in frontend), :steps_for => steps(:all), :type => RailsStory do

  Scenario "An admin deletes a blog article" do
    Given "a blog has an article"
      And "the user is logged in as admin"
    When "the user visits the blog page"
    Then "the page has a list of articles"
    When "the user clicks on 'test article'"
    Then "the page has a article editing form"
    When "the user clicks on 'Delete this article'"
    Then "the user is redirected to the blog's articles page"
      And "an article with title 'test article' is deleted"
  end
end
