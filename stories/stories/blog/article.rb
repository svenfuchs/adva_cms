require File.expand_path(File.dirname(__FILE__) + "/../../helper")

Story "Viewing a blog article page", %(
  As an anonymous visitor 
  I want to access the blog article page
  So I can read the full article), :steps_for => steps(:default, :blog, :article), :type => RailsStory do

  Scenario "An blog article page" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page shows the article title"
    Then "the page shows the article excerpt"
    Then "the page shows the article body"
    Then "the page does not show read the rest of this entry"
  end

  Scenario "An blog article page with commenting allowed" do
    Given "an article"
    And "the article is published"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page has a form posting to /comments"
  end

  Scenario "An blog article page with commenting not allowed" do
    Given "an article"
    And "the article is published"
    And "the article does not allow commenting"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page does not have a form posting to /comments"
  end

  Scenario "An blog article page with an approved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    And "the comment is approved"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page shows the comment body"
    Then "the page shows 1 comment"
  end

  Scenario "An blog article page with an unapproved comment" do
    Given "an article"
    And "the article is published"
    And "the article has a comment"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page does not show the comment body"
    Then "the page does not show 1 comment"
  end

  Scenario "An blog article page for an unpublished article" do
    Given "an article"
    And "the article is not published"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the user is redirected to /login"
  end

  Scenario "An blog article page for non existing article" do
    When "the user GETs /2008/1/1/the-article-title"
    Then "the request does not succeed"
  end
end

Story "Previewing a blog article page", %(
  As an admin
  I want to access an unpublished blog article's page
  So I can preview it), :steps_for => steps(:default, :article, :user), :type => RailsStory do

  Scenario "An blog article page for an unpublished article" do
    Given "an article"
    And "the article is not published"
    And "the user is logged in as admin"
    When "the user GETs /2008/1/1/the-article-title"
    Then "the page shows the article title"
  end
end