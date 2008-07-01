require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Publishing a blog article", %(
  As an admin
  I want to write blog articles in the admin area
  So they get published in the frontend), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin writes a blog article" do
    Given "a blog with no articles"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections/1/articles"
    Then "the page has an empty list of articles"
    When "the user GETs /admin/sites/1/sections/1/articles/new"
    Then "the page has a form posting to /admin/sites/1/sections/1/articles"
    And "the 'safe as draft' checkbox is checked"
    When "the user POSTs to", '/admin/sites/1/sections/1/articles', :article => valid_article_attributes.update(:draft => 1)
    Then "a new article is saved"
    And "the user is redirected to /admin/sites/1/sections/1/articles/1"
  end
end