require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Viewing a blog index page", %(
  As an anonymous visitor 
  I want to access the blog index pages
  So I can see all the cool blog articles), :steps_for => steps(:all), :type => RailsStory do

  Scenario "An empty blog index page" do
    Given "an article"
    And "the article is not published"
    When "the user GETs /"
    Then "the page does not show the article title"
  end

  Scenario "A blog index page with an article that has an exerpt" do
    Given "an article"
    And "the article is published"
    When "the user GETs /"
    Then "the page shows the article title"
    Then "the page shows the article excerpt"
    Then "the page does not show the article body"
    Then "the page shows read the rest of this entry"
    Then "the page shows 0 comments"
  end

  Scenario "A blog index page with an article that has an approved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    And "the comment is approved"
    When "the user GETs /"
    Then "the page shows 1 comment"
  end

  Scenario "A blog index page with an article that has an unapproved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    When "the user GETs /"
    Then "the page shows 0 comments"
  end

  Scenario "A blog index page with an article that does not have an exerpt" do
    Given "an article that has $options", :excerpt => nil
    And "the article is published"
    When "the user GETs /"
    Then "the page shows the article title"    
    Then "the page does not show the article excerpt"
    Then "the page shows the article body"
    Then "the page does not show read the rest of this entry"   
  end
  
  Scenario "An empty blog category index page" do
    Given "an article"
    And "the article is published"
    And "an unrelated category"
    When "the user GETs /categories/an-unrelated-category"
    Then "the page does not show the article title"
  end
  
  Scenario "A blog category index page with an article" do
    Given "an article"
    And "the article is published"
    When "the user GETs /categories/a-category"
    Then "the page shows the article title"
  end
  
  Scenario "An empty blog tag index page" do
    Given "an article"
    And "the article is published"
    And "an unrelated tag"
    When "the user GETs /tags/baz"
    Then "the page does not show the article title"
  end

  Scenario "A blog tag index page with an article" do
    Given "an article"
    And "the article is published"
    When "the user GETs /tags/foo"
    Then "the page shows the article title"
  end
  
  Scenario "An empty blog year archive page" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2007"
    Then "the page does not show the article title"
  end
  
  Scenario "A blog year archive page with an article" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008"
    Then "the page shows the article title"
  end
  
  Scenario "An empty blog month archive page" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2007/1"
    Then "the page does not show the article title"
  end
  
  Scenario "A blog month archive page with an article" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008/1"
    Then "the page shows the article title"  
  end
end