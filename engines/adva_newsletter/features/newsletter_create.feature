Feature: Create Newsletter
  Scenario: Admin creates a newsletter
    Given I am logged in as 'admin'
    When I go to '/admin/sites/1/newsletters'
    And click 'Create a newsletter'
    And submit new 'newsletter'
    Then I should see 'newsletter' on the 'list of newsletters'
    And 'newsletter' should have 0 times sent out
    
  Scenario: Site admin creates a newsletter with variable
    Given I am logged in as 'admin'
    And 'site user' is subscribed to 'newsletter'
    When I submit new 'newsletter' with 'body' what contains 'Hello {{ user.name }}!'
    Then 'site user' should receive newsletter with user name
