require File.expand_path(File.dirname(__FILE__) + "/../../helper")

# TODO diffs, lists

Story "Viewing a wiki page", %(
  As a visitor 
  I want to access a wiki's pages
  So I can read all the useful information), :steps_for => steps(:all), :type => RailsStory do

  Scenario "Viewing an empty wiki" do
    Given "a wiki"
    And "no home wikipage"
    When "the user GETs /"
    Then "the page has a form posting to /"
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
    When "the user GETs /pages/a-wikipage"
    Then "the page shows the wikipage body"
    And "the edit link is only visible for certain roles"
  end

  Scenario "Viewing a wikipage revision" do
    Given "a wiki"
    And "a wikipage"
    And "the wikipage has a revision"
    When "the user GETs /pages/a-wikipage/rev/1"
    Then "the page shows the wikipage body (versioned)"
    And "the edit link is only visible for certain roles"
    And "the page has a rollback link putting to the version number to /pages/a-wikipage"
  end
end