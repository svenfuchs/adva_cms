require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

valid_install_params = {}

Story "Install", %(
  As a user
  I can install the initial site from a web form
  So I can get going quickly), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "The install page" do
    Given "no site present"
    And "no admin account present"
    When "the user GETs /"
    Then "the admin/install/index template is rendered"
    And "the page has a form posting to admin/install"
  end
  
  Scenario "A user installs the intial site" do
    Given "no site present"
    And "no admin account present"
    When "a user POSTs to", "/install", valid_install_params
    Then "a new site is saved"
    And "a the root section is saved"
    And "an admin account is created"
    And "an admin account is verified"
    And "the user is authenticated as the admin"
  end
end