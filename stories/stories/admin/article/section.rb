require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Publishing a section article", %(
  As an admin
  I want to write section articles in the admin area
  So they get published in the frontend), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin writes a section article" do
    Given "a section with no articles"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections/1/articles"
    Then "the page has an empty list of articles"
    When "the user GETs /admin/sites/1/sections/1/articles/new"
    Then "the page has a form posting to /admin/sites/1/sections/1/articles"
    And "the 'safe as draft' checkbox is checked"
    When "the user POSTs to", '/admin/sites/1/sections/1/articles', :article => valid_article_attributes.update(:draft => 1)
    Then "a new article is saved"
    And "the article has a position set"
    And "the user is redirected to /admin/sites/1/sections/1/articles/1"
  end
end

Story "Reordering section articles", %(
  As an admin
  I want to reorder section articles
  So I can control which article is displayed as the primary article), :steps_for => steps(:all), :type => RailsStory do

  Scenario "An admin reorders section articles" do
    Given "a section with two articles"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/sections/1"
    Then "the page has a reorder articles link"
    When "the user PUTs to", '/admin/sites/1/sections/1/articles', :articles => {"1" => {"position" => "1"}, "2" => {"position" => "0"}}
    Then "the second article is sorted to the top"
  end
end