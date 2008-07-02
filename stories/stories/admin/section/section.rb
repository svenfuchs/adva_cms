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
    Then "the page has a form posting to /admin/sites/1/sections/1/articles"
    And "the 'safe as draft' checkbox is checked"
    When "the user POSTs to", '/admin/sites/1/sections/1/articles', :article => valid_article_attributes.update(:draft => 1)
    Then "a new article is saved"
    And "the article has a position set"
    And "the user is redirected to /admin/sites/1/sections/1/articles/1"
  end
end