Feature: Create newsletter issue
  Scenario: Admin creates a draft issue
    Given I am logged in as "admin"
    And have opened some "newsletter"
    When I click "Create a new issue"
    And submit new "draft issue"
    Then I should see new "draft issue"
    
  Scenario: Admin creates an empty issue
    Given I am logged in as "admin"
    And have opened some "newsletter"
    When I click "Create a new issue"
    And submit new "empty issue"
    Then I should see validation error messages

  Scenario: Admin sends out newsletter issue
    Given PENDING
    Given I am logged in as "admin"
    And I have a "newsletter" with "subscribers"
    When I submit "issue" and uncheck "Draft?"
    Then "subscribers" should receive "issue"

  Scenario: Admin sends out issue with 2 hours delay
    Given PENDING
    Given I am logged in as "admin"
    And I have a "newsletter" with "subscribers"
    When I submit "issue" and uncheck "Draft?" and pick "2 hours" in the future
    Then I should see "issue" in the "issue queue"
    And "subscribers" should receive "issue" with "2 hours" delay
    
  Scenario: Site admin sends out test issue
    Given PENDING
    Given I am logged in as "admin"
    And I have a "newsletter" with "subscribers"
    When I open "issue" and click button "Test delivery"
    Then only I receive "issue"

  Scenario: Site admin creates a personalised issue
    Given PENDING
    Given I am logged in as "admin"
    And only I am subscribed to "newsletter"
    When I submit new "issue" with "body" what contains "Hello {{ user.name }}!"
    Then I should receive newsletter with my name

  Scenario: Site admin cancels delayed issue
    Given PENDING
    Given I am logged in as "admin"
    And I have delayed "issue" in the "issues queue"
    When I click "cancel issue" at the "issue page"
    Then "issue" should be cancelled
    And I should not see "issue" at the "issues queue"
