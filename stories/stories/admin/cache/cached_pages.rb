require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing cached pages", %(
  As an admin
  I want to manage my site's cached pages
  So I can manually control the cache), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin views the cached pages list" do
    Given "a blog with no pages cached"
    And "the user is logged in as admin"
    When "the user GETs /admin/site/1/cached_pages"
    Then "the page has an empty list of cached pages"
    Given "a cached page"
    When "the user GETs /admin/site/1/cached_pages"
    Then "the page has list of cached pages with one object"
    And "the page has a link to expire all cached pages"
    And "the page has a link to expire the cached page"
  end
  
  Scenario "An admin expires a cached page manually" do
    Given "a blog with no pages cached"
    And "a cached page"
    When "the user DELETEs /admin/sites/1/cached_pages/1"
    Then "the cached page's record and file are deleted"
  end
  
  Scenario "An admin expires all cached pages manually" do
    Given "a blog with no pages cached"
    And "a cached page"
    And "another cached page"
    When "the user DELETEs /admin/sites/1/cached_pages"
    Then "the cached page's record and file are deleted"
    And "the other cached page's record and file are deleted"
  end
end