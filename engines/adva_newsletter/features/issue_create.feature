Feature: Create newsletter issue
  Scenario: Admin creates a draft issue
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters/1"
    And click "Create a new issue"
    And submit new "draft issue"
    Then I should see new "draft issue"
    And should have 0 deliveries
    
  Scenario: Admin creates an empty issue
    Given I am logged in as "admin"
    When I go to "/admin/sites/1/newsletters/1/issues/new"
    And submit new "empty issue"
    Then I should see "can't be blank"

  Scenario: Site admin creates a personalised newsletter
    Given PENDING
    Given I am logged in as "admin"
    And "site user" is subscribed to "newsletter"
    When I submit new "newsletter" with "body" what contains "Hello {{ user.name }}!"
    Then "site user" should receive newsletter with user name

  Scenario: Site admin sends out issue
    Given PENDING
    Given I am logged in as 'site admin'
    And I have a 'newsletter' with 'subscribers'
    When I open 'newsletter' and click 'Issue'
    Then 'subscribers' should receive 'newsletter'

  Scenario: Site admin sends out test issue
    Given PENDING
    Given I am logged in as 'site admin'
    And I have a 'newsletter' with 'subscribers'
    When I open 'newsletter' and click 'Test Issue'
    Then only I receive 'newsletter'

  Scenario: Site admin sends out newsletter with 2 hours delay
    Given PENDING
    Given I am logged in as 'site admin'
    And I have a 'newsletter' with 'subscribers'
    When I open 'newsletter' and select '2 hours' delay
    Then I should see 'newsletter' in the 'newsletter queue'
    And 'subscribers' should receive 'newsletter' with '2 hours' delay
    
  Scenario: Site admin cancels delayed newsletter
    Given PENDING
    Given I am logged in as 'site admin'
    And I have delayed 'newsletter' in the 'newsletter queue'
    When I click 'cancel issue' at the 'newsletter page'
    Then 'newsletter' issue should be cancelled
    And I should not see 'newsletter' at the 'newsletter queue'
