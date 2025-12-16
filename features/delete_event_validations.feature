# features/delete_event_validations.feature

Feature: Delete Event Restrictions
  As a student
  I want only event creators to delete events
  So that events are properly protected

  Background:
    Given the following events exist:
      | title      | description | date       | time  | location  | tags  |
      | My Event   | My event    | 2026-01-15 | 14:00 | Hall A    | Tech  |
      | Other Event| Not mine    | 2026-01-16 | 15:00 | Hall B    | Social|

  @javascript
  Scenario: Creator can delete their own event
    Given I am the creator of "My Event"
    When I visit the events index page
    And I click delete for "My Event"
    And I confirm the deletion
    Then I should not see "My Event"
    And I should see "Other Event"

  Scenario: Non-creator cannot see delete button
    Given I am not the creator of "Other Event"
    When I visit the events index page
    Then I should not see delete button for "Other Event"

  Scenario: Deleting event also deletes associated upvotes
    Given I am the creator of "My Event"
    And "My Event" has 5 upvotes
    When I visit the events index page
    And I click delete for "My Event"
    Then the upvotes for "My Event" should also be deleted

@javascript
  Scenario: Confirm deletion prompt appears
    Given I am the creator of "My Event"
    When I visit the events index page
    And I click delete for "My Event"
    Then I should see a confirmation dialog
    When I confirm the deletion
    Then I should not see "My Event"

@javascript
  Scenario: Can cancel deletion
    Given I am the creator of "My Event"
    When I visit the events index page
    And I click delete for "My Event"
    And I cancel the deletion
    Then I should see "My Event"

  Scenario: Event count updates after deletion
    Given I am the creator of "My Event"
    When I visit the events index page
    Then I should see 2 events
    When I click delete for "My Event"
    Then I should see 1 event