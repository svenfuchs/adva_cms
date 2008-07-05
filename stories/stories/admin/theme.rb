require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

valid_theme_attributes = {
  :name => 'the theme name'
}

Story "Managing themes", %(
  As an admin
  I want to manage my site's themes
  So I can change the site's look and feel), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin creates a new theme" do
    Given "a site"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/themes"
    Then "the page has an empty list of sites"
    When "the user GETs /admin/sites/1/themes/new"
    Then "the page has a form posting to /admin/sites/1/themes"
    When "the user POSTs to", '/admin/sites/1/themes', :theme => valid_theme_attributes
    Then "a new theme is saved"
    And "the user is redirected to /admin/sites/1/themes"
  end
  
  Scenario "An admin updates a theme's settings" do
    Given "a site with a theme"
    And "the user is logged in as admin"
    When "the user GETs /admin/sites/1/themes/the-theme-name"
    Then "the page has a form putting to /admin/sites/1/themes/the-theme-name"
    When "the user PUTs to", '/admin/sites/1/themes/the-theme-name', :section => valid_site_attributes(:author => 'updated author')
    Then "the theme's author is 'updated author'"
  end
end