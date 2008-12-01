Feature: Newsletter list
  Scenario: No newsletters
    Given I am logged in as "admin"
    And there are no newsletters
    When I go to "/admin/sites/1/newsletters"
    Then I should see "There are no newsletters."
