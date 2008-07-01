require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Managing assets", %(
  As an admin
  I want to manage my site's assets
  So I can get use them on the site), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin views the assets list" do
    Given "a blog with no assets"
    And "the user is logged in as admin"
    When "the user GETs /admin/site/1/assets"
    Then "the page has an empty list of assets"
  end
  
  Scenario "An admin uploads an asset" do
    Given "a blog with no assets"
    And "the user is logged in as admin"
    When "the user GETs /admin/site/1/assets/new"
    Then "the page has form posting to /admin/site/1/assets"
    When "the user POSTs to", '/admin/site/1/assets', "assets"=>[{"uploaded_data" => 'file', "title" => "title", "tag_list" => "foo bar"}]
    Then "a new asset is saved"
    And "the user is redirected to /admin/sites/1/assets"
    When "the user follows the redirect"
    Then "the page has a list of assets with one asset"
  end
end