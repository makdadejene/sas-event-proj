# features/private_event_validations.feature
Feature: Private Event Restrictions
  As a student
  I want private events to be properly restricted
  So that only authorized users can see them

  Background:
    Given the following events exist:
      | title        | description | date       | time  | location    | tags   |
      | Public Event | Open to all | 2026-01-15 | 14:00 | Main Hall   | Social |

  Scenario: Private events not visible to logged out users on index
    Given I create a private event "Private Meeting"
    When I log out
    And I visit the events index page
    Then I should see "Public Event"
    And I should not see "Private Meeting"

  Scenario: Creator can see their own private events
    Given I create a private event "Private Meeting"
    And I am the creator of "Private Meeting"
    When I visit the events index page
    Then I should see "Private Meeting"
    And I should see "Public Event"

  Scenario: Private checkbox creates private event
    Given I am on the new event page
    When I fill in "Title" with "Secret Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Private Room"
    And I check "Private Event"
    And I press "Submit"
    Then I should see "Secret Event"

  Scenario: Private events show privacy indicator
    Given I create a private event "Private Meeting"
    And I am the creator of "Private Meeting"
    When I visit the events index page
    Then I should see a privacy indicator for "Private Meeting"

  Scenario: Public events are visible to everyone
    Given I visit the events index page
    Then I should see "Public Event"

  Scenario: Cannot filter private events you cannot see by tags
    Given I create a private event "Private Tech Talk" with tags "Tech"
    And I create a public event "Public Tech Event" with tags "Tech"  # Add a public event with same tag
    When I log out
    And I visit the events index page
    And I click on tag "Tech"
    Then I should see "Public Tech Event"
    And I should not see "Private Tech Talk"