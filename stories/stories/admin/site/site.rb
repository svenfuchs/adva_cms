require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing sites", %(
  As an admin
  I want to manage my sites
  So I can add, update and delete sites), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new site" do
    Given "no site"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites"
    Then "the page has an empty list of sites"
    When "the user GETs /admin/sites/new"
    Then "the page has a form posting to /admin/sites"
    When "the user POSTs to", '/admin/sites', :site => valid_site_attributes
    Then "a new site is saved"
    And "the user is redirected to /admin/sites/1"
  end
  
  Scenario "An admin updates a site" do
    Given "a site"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/edit"
    Then "the page has a form putting to /admin/sites/1"
    When "the user PUTs to", '/admin/sites/1', :section => valid_site_attributes(:title => 'updated title')
    Then "the site's title is 'updated title'"
  end
end