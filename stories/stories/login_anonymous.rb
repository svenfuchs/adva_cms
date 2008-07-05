require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Anonymous login", %(
  As an anonymous user
  I can post my name, email and homepage
  So the system remembers me as an anonymous user), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "A user posts as an anonymous" do
    Given "no anonymous accounts exist"
    And "the user has POSTed to", "/comments", :comment => valid_comment_attributes, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "an anonymous account exists"
    When "the user GETs /comments/1"
    Then "the system authenticates the user as a known anonymous" 
  end
end