Feature: Subscribe to newsletter
  Scenario: Visitor subscribes to the newsletter
    Given I am not logged in
    When I submit 'signup form' with selected value 'Subscribe to the newsletter'
    And click 'confirmation link' when I receive confirmation email
    Then I am subscribed to the 'newsletter'
    
  Scenario: Site admin adds a new subscription to the newsletter
    Given I am logged in as 'site admin'
    When I open 'newsletter' and click 'Add a new subscriber'
    And submit 'subscriber form' with 'user' values
    Then 'user' should be subscribed 'newsletter'
    And I should see 'user' at 'Newsletter Subscriptions' page
