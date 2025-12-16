# features/core_events.feature
Feature: Core Event Management
  As a student
  I want to manage campus events
  So that I can stay connected with campus activities

Background: Sample events exist
  Given the following events exist:
    | title         | description          | date       | time  | location    | tags          |
    | Soccer Game   | Fun pickup game      | 2026-01-06 | 16:00 | Sports Hall | sports, other |
    | Movie Night   | Watch movies together| 2026-01-05 | 23:00 | Cinema Room | club, social  |
    | Yoga Session  | Morning yoga         | 2026-01-16 | 08:30 | Sports Hall | sports, other |

  Scenario: View all events on the homepage
    When I visit the events index page
    Then I should see "Soccer Game"
    And I should see "Movie Night"
    And I should see "Yoga Session"

  Scenario: Events display their details
    When I visit the events index page
    Then I should see "Soccer Game"
    And I should see "Fun pickup game"
    And I should see "Jan 06, 2026"
    And I should see "04:00 PM"

  Scenario: Navigate to create event page
    When I visit the events index page
    And I click on the add event button
    Then I should be on the new event page
    And I should see "Create an event"

  Scenario: Successfully create a new event
  Given I am on the new event page
  When I fill in "Title" with "Dance Workshop"
  And I fill in "Description" with "Learn new moves"
  And I fill in "Date" with "2026-01-15"       
  And I fill in "Start Time" with "14:00"
  And I fill in "End Time" with "16:00"
  And I fill in "Location" with "Room 101"       
  And I press "Submit"
  Then I should see "Dance Workshop"

  Scenario: Sort events alphabetically
    When I visit the events page with sort option "alphabetical"
    Then I should see "Movie Night" before "Soccer Game"
    And I should see "Soccer Game" before "Yoga Session"

  Scenario: Sort events by earliest date first
    When I visit the events page with sort option "date"
    Then I should see "Movie Night" before "Soccer Game"
    And I should see "Soccer Game" before "Yoga Session"

  Scenario: Sort events by latest date first
    When I visit the events page with sort option "date-desc"
    Then I should see "Yoga Session" before "Soccer Game"
    And I should see "Soccer Game" before "Movie Night"

  Scenario: Events display individual tags
    When I visit the events index page
    Then I should see "Sports"
    And I should see "Club"
    And I should see "Social"

  Scenario: Create event with minimal information
  Given I am on the new event page
  When I fill in "Title" with "Study Session"
  And I fill in "Date" with "2026-01-20"
  And I fill in "Start Time" with "10:00"
  And I fill in "End Time" with "11:00"
  And I fill in "Location" with "Library"
  And I press "Submit"
  Then I should see "Study Session"
    Then I should see "Study Session"

  Scenario: Return to event list after creating event
    Given I am on the new event page
    When I fill in "Title" with "Book Club"
    And I fill in "Date" with "2025-12-01"
    And I fill in "Time" with "18:00"
    And I press "Submit"
    Then I should be on the events index page

  Scenario: Fail to create an event without a title
    Given I am on the new event page
    When I fill in "Description" with "No title here"
    And I fill in "Date" with "2025-12-10"
    And I fill in "Time" with "17:00"
    And I press "Submit"
    Then I should see "Title can't be blank"
