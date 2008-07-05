require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Rolling back a wikipage to a previous revision", %(
  As a user with a given role
  I want to rollback a wikipage to a previous revision
  So the wikipage has the old content), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An anonymous user rolls back a wikipage (in a wiki that allows it)" do
    Given "a wiki that allows anonymous users to create and update wikipages"
    And "a wikipage that has a revision"
    When "the user PUTs to", "/pages/the-wikipage-title", {:version => 1}
    Then "a new version of the wikipage is created"
    And "the wikipage has the attributes $attributes", :body => 'the old wikipage body'
  end
  
  Scenario "An anonymous user can not rollback a wikipage (because required permissions are missing)" do
    Given "a wiki that allows registered users to create and update wikipages"
    And "a wikipage that has a revision"
    When "the user PUTs to", "/pages/the-wikipage-title", {:version => 1}
    Then "the user is redirected to /login"
  end
end