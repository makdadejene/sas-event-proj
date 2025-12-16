# features/edit_event_validations.feature
Feature: Edit Event Restrictions
  As a student
  I want only event creators to edit events
  So that events are properly managed

  Background:
    Given the following events exist:
      | title      | description | date       | time  | location  | tags  |
      | My Event   | My event    | 2026-01-15 | 14:00 | Hall A    | Tech  |
      | Other Event| Not mine    | 2026-01-16 | 15:00 | Hall B    | Social|

  Scenario: Creator can edit their own event
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    And I fill in "Title" with "Updated Event"
    And I press "Submit"
    Then I should see "Updated Event"
    And I should be on the events index page

  Scenario: Non-creator cannot access edit page
    Given I am not the creator of "Other Event"
    When I visit the edit page for "Other Event"
    Then I should see "You are not authorized to edit this event"
    Then I should be redirected to the events index page

  Scenario: Cannot edit event to have invalid data
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    And I fill in "Title" with ""
    And I press "Submit"
    Then I should see "Title can't be blank"

  Scenario: Cannot change event date to the past when editing
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    And I fill in "Date" with "2020-01-01"
    And I press "Submit"
    Then I should see "Date must be in the future"

  Scenario: Cannot set end time before start time when editing
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    And I fill in "Start Time" with "18:00"
    And I fill in "End Time" with "16:00"
    And I press "Submit"
    Then I should see "End time must be after start time"

  Scenario: Can successfully update event details
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    And I fill in "Description" with "Updated description"
    And I fill in "Location" with "New Location"
    And I press "Submit"
    Then I should see "Updated description"
    And I should see "New Location"

  Scenario: Edit form displays current event data
    Given I am the creator of "My Event"
    When I visit the edit page for "My Event"
    Then the "Title" field should contain "My Event"
    And the "Description" field should contain "My event"
    And the "Location" field should contain "Hall A"