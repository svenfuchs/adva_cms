Feature: Create Newsletter
  Scenario: Admin creates a newsletter
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters"
    And click "Create a newsletter"
    And submit new "newsletter"
    Then I should see "newsletter"
    And should have 0 issues
    
  Scenario: Admin creates an empty newsletter
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters/new"
    And submit new "empty newsletter"
    Then I should see validation error messages
