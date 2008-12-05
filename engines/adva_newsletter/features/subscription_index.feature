Feature: List of subscribers
  Scenario: Admin views list but there are no subscribers
    Given I am logged in as "admin"
    And there are no subscriptions
    And I have opened some "newsletter"
    When I click "Subscribers"
    Then I should see "There are no subscribers."
    And I should see a link "Add a new subscriber"
