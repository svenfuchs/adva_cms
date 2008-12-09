Feature: Subscribe to newsletter
  Scenario: Visitor subscribes to the newsletter
    Given PENDING
    Given I am not logged in
    When I submit "signup form" with selected value "Subscribe to the newsletter"
    And click "confirmation link" when I receive confirmation email
    Then I am subscribed to the "newsletter"
