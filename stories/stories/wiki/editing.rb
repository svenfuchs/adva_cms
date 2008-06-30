require File.expand_path(File.dirname(__FILE__) + "/../../helper")

# TODO creating, deleting

valid_wikipage_attributes = {}
invalid_wikipage_attributes = {}

Story "Editing a wikipage", %(
  As a user with a given role
  I want to edit a wikipage 
  So I can contribute to the wiki), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An anonymous user edits a wikipage (in a wiki that allows it)" do
    Given "a wiki that allows anonymous users to create and update wikipages"
    And "a wikipage"
    When "the user GETs /pages/the-wikipage-title/edit"
    Then "the page has a form putting to /pages/the-wikipage-title"
    And "the form contains an input tag with $attributes", {:name => 'anonymous[name]'}
    And "the form contains an input tag with $attributes", {:name => 'anonymous[email]'}
  end
  
  # Scenario "A recurring anonymous user edits a wikipage (in a wiki that allows it)" do
  #   Given "a wiki"
  #   And "a wikipage"
  #   And "the wiki has :update permissions for anonymous users"
  #   And "the user is a recurring anonymous"
  #   When "the user GETs /pages/a-wikipage/edit"
  #   Then "the form fields for the anonymous author's name and email are pre-filled with his name and email"
  # end

  Scenario "An anonymous user can not edit a wikipage (because required permissions are missing)" do
    Given "a wiki that allows registered users to create and update wikipages"
    And "a wikipage"
    When "the user GETs /pages/the-wikipage-title/edit"
    Then "the user is redirected to /login"
  end
  
  Scenario "A registered user edits a wikipage (in a wiki that allows it)" do
    Given "a wiki that allows registered users to create and update wikipages"
    And "a wikipage"
    And "the user is logged in as user"
    When "the user GETs /pages/the-wikipage-title/edit"
    Then "the page has a form putting to /pages/the-wikipage-title"
    And "the form does not contain an input tag with $attributes", {:name => 'anonymous[name]'}
    And "the form does not contain an input tag with $attributes", {:name => 'anonymous[email]'}
  end
end

Story "Saving a wikipage", %(
  As a user with a given role
  I want to submit the wikipage edit form
  So I can save my changes), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An anonymous user saves a wikipage (in a wiki that allows it)" do
    Given "a wiki that allows anonymous users to create and update wikipages"
    And "a wikipage"    
    When "the user PUTs to", "/pages/the-wikipage-title", :wikipage => {:body => 'updated wikipage body', :updated_at => Time.now}, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "a new version of the wikipage is created"
    And "the user is redirected to /pages/the-wikipage-title"
  end

  Scenario "An anonymous user can not save a wikipage (because required permissions are missing)" do
    Given "a wiki that allows registered users to create and update wikipages"
    And "a wikipage"
    When "the user PUTs to", "/pages/the-wikipage-title", :wikipage => {:body => 'updated wikipage body', :updated_at => Time.now}, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "the user is redirected to /login"
    # TODO redirect to /login is crap, isn't it
  end
  
  Scenario "Trying to save a wikipage with invalid data" do
    Given "a wiki that allows anonymous users to create and update wikipages"
    And "a wikipage"
    When "the user PUTs to", "/pages/the-wikipage-title", :wikipage => {:body => nil, :updated_at => Time.now}, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "the wiki/edit template is rendered"
    And "the flash contains an error message"
  end
end
