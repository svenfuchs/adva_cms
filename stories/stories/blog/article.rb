require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Viewing a blog article page", %(
  As an anonymous visitor 
  I want to access the blog article page
  So I can read the full article), :steps_for => steps(:default, :article), :type => RailsStory do

  Scenario "An blog article page" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page shows the article title"
    Then "the page shows the article excerpt"
    Then "the page shows the article body"
    Then "the page does not show read the rest of this entry"
    Then "the page has a comment form tag"
  end

  Scenario "An blog article page with commenting allowed" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page has a comment form tag"
  end

  Scenario "An blog article page with commenting not allowed" do
    Given "an article"
    And "the article is published"
    And "the article does not allow commenting"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page does not have a comment form tag"
  end

  Scenario "An blog article page with an approved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    And "the comment is approved"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page shows the comment body"
  end

  Scenario "An blog article page with an unapproved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page does not show the comment body"
  end
end