Feature: Subscribe to newsletter
  Scenario: Admin adds subscriber to the newsletter
    Given I am logged in as "admin"
    And site has users
    And I have opened some "newsletter"
    When I click "Add a new subscriber"
    And submit new "subscription"
    Then "user" should be subscribed "newsletter"
    And I should see "user" at "Newsletter Subscriptions" page

  Scenario: Admin adds subscriber but site has no users
    Given I am logged in as "admin"
    And site has no users
    And I have opened some "newsletter"
    When I click "Add a new subscriber"
    Then I should see "Site does not have any users."
    And I should see a link "Add a new user"

  Scenario: Visitor subscribes to the newsletter
    Given PENDING
    Given I am not logged in
    When I submit "signup form" with selected value "Subscribe to the newsletter"
    And click "confirmation link" when I receive confirmation email
    Then I am subscribed to the "newsletter"
