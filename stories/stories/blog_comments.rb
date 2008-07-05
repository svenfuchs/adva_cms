require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Commenting on an article", %(
  As a user with a given role
  I want to comment on an article (in a blog that allows so)
  So I can share my opinions), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An anonymous user comments on an article" do
    Given "a blog that allows anonymous users to create comments"
    And "a published article"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page has a form posting to /comments"
    And "the form contains an input tag with $attributes", {:name => 'anonymous[name]'}
    And "the form contains an input tag with $attributes", {:name => 'anonymous[email]'}
  end
  
  Scenario "An anonymous user submits a comment on an article" do
    Given "a blog that allows anonymous users to create comments"
    And "a published article"
    And "no comments exist"
    When "the user POSTs to", "/comments", :comment => valid_comment_attributes, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "a comment exists"
    And "the user is redirected to /comments/1"
  end
  
  Scenario "An anonymous user updates a comment that he has submitted" do
    Given "no comments exist"
    And "the user has POSTed to", "/comments", :comment => valid_comment_attributes, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    When "the user GETs /comments/1"
    Then "the page shows the comment body"
    Then "the page has a form putting to /comments/1"
    And "the form contains an input tag with $attributes", {:name => 'anonymous[name]', :value => 'anonymous'}
    And "the form contains an input tag with $attributes", {:name => 'anonymous[email]', :value => 'anonymous@email.org'}
    When "the user PUTs to", "/comments/1", :comment => {:body => 'the updated comment body'}, :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'}
    Then "the comment is updated"
  end
end

  
  # Scenario "A recurring anonymous user comments on an article" do
  #   Given "a blog that allows anonymous users to create comments"
  #   And "a published article"
  #   And "the user is recognized as a recurring anonymous"
  #   When "the user GETs /2008/1/1/the-article-title"
  #   Then "the page has a form posting to /comments"
  #   And "the form contains an input tag with $attributes", {:name => 'anonymous[name]', :value => 'anonymous'}
  #   And "the form contains an input tag with $attributes", {:name => 'anonymous[email]', :value => 'anonymous@email.org'}
  # end