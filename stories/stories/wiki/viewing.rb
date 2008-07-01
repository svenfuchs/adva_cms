require File.expand_path(File.dirname(__FILE__) + "/../../helper")

# TODO diffs, lists

Story "Viewing a wiki page", %(
  As a visitor 
  I want to access a wiki's pages
  So I can read all the useful information), :steps_for => steps(:all), :type => RailsStory do

  Scenario "Viewing an empty wiki" do
    Given "a wiki that allows anonymous users to create and update wikipages"
    And "no wikipage"
    When "the user GETs /"
    Then "the page has a form posting to /pages"
  end
  
  Scenario "Viewing the wiki home wikipage" do
    Given "a wiki"
    And "a home wikipage"
    When "the user GETs /"
    Then "the page shows the home wikipage body"
    And "the edit link is only visible for certain roles"
  end
  
  Scenario "Viewing a wikipage" do
    Given "a wiki"
    And "a wikipage"
    When "the user GETs /pages/the-wikipage-title"
    Then "the page shows the wikipage body"
    And "the edit link is only visible for certain roles"
  end
  
  Scenario "Viewing a wikipage revision" do
    Given "a wiki"
    And "a wikipage that has a revision"
    When "the user GETs /pages/the-wikipage-title/rev/1"
    Then "the page shows the old wikipage body"
    And "the page has a rollback link putting to the version number to /pages/the-wikipage-title"
  end
end