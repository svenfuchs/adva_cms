Feature: Events Creation
  In order to organize meetings
  As a manager
  I want to plan events

  Scenario: Create a draft event
    Given I am a logged user
    When I am on the new events page
    And I create a meeting as draft event
    Then I should see the meeting event in the events page
