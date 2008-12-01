Feature: Create Newsletter
  Scenario: Admin creates a draft newsletter
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters"
    And click "Create a newsletter"
    And submit new "draft newsletter"
    Then I should see new "draft newsletter"
    And should have 0 issues
    
  Scenario: Admin creates an empty newsletter
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters/new"
    And submit new "empty newsletter"
    Then I should see "can't be blank"

  Scenario: Site admin creates a personalised newsletter
    Given PENDING
    Given I am logged in as "admin"
    And "site user" is subscribed to "newsletter"
    When I submit new "newsletter" with "body" what contains "Hello {{ user.name }}!"
    Then "site user" should receive newsletter with user name
