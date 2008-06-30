require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Rolling back a wikipage to a previous revision", %(
  As a user with a given role
  I want to rollback a wikipage to a previous revision
  So the wikipage has the old content), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An anonymous user rolls back a wikipage (in a wiki that allows it)" do
    Given "a wiki"
    And "a wikipage"
    And "the wikipage has a revision"
    And "the wiki has :update permissions for anonymous users"
    When "the user PUTs an old version number to /pages/a-wikipage"
    Then "a new wikipage version is created"
    And "the wikipage has the content from the old version"
  end
  
  Scenario "An anonymous user can not rollback a wikipage (because required permissions are missing)" do
    Given "a wiki"
    And "a wikipage"
    And "the wiki has :update permissions for registered users"
    And "the user is logged in as user"
    When "the user PUTs an old version number to /pages/a-wikipage"
    Then "what?"
  end
end