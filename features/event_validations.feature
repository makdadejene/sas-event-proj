# features/event_validations.feature

Feature: Event Validation Rules
  As a student
  I want the system to validate event data
  So that only valid events are created

  Background:
    Given I am on the new event page

  # date & time
  Scenario: Cannot create event with past date
    When I fill in "Title" with "Past Event"
    And I fill in "Date" with "2020-01-01"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Date must be in the future"
    And I should be on the new event page

  Scenario: Cannot create event with end time before start time
    When I fill in "Title" with "Time Paradox Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Start Time" with "18:00"
    And I fill in "End Time" with "16:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "End time must be after start time"
    And I should be on the new event page

  Scenario: Cannot create event with same start and end time
    When I fill in "Title" with "Instant Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Start Time" with "14:00"
    And I fill in "End Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "End time must be after start time"

  Scenario: Successfully create event with valid time range
    When I fill in "Title" with "Valid Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Start Time" with "14:00"
    And I fill in "End Time" with "16:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Valid Event"
    And I should be on the events index page

  Scenario: Can create event without end time
    When I fill in "Title" with "No End Time Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Start Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "No End Time Event"

  # required field
  Scenario: Cannot create event without title
    When I fill in "Description" with "No title event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Title can't be blank"
    And I should be on the new event page

  Scenario: Cannot create event without date
    When I fill in "Title" with "No Date Event"
    And I fill in "Description" with "Missing date"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Date can't be blank"

  Scenario: Cannot create event without start time
    When I fill in "Title" with "No Time Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Start time can't be blank"

  Scenario: Cannot create event without location
    When I fill in "Title" with "No Location Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I press "Submit"
    Then I should see "Location can't be blank"

  # titles
  Scenario: Title must be at least 3 characters
    When I fill in "Title" with "AB"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Title is too short (minimum is 3 characters)"

  Scenario: Title cannot exceed 100 characters
    When I fill in "Title" with "This is an extremely long title that exceeds the maximum allowed length of one hundred characters for event titles"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Title is too long (maximum is 100 characters)"

  Scenario: Title with exactly 3 characters is valid
    When I fill in "Title" with "ABC"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "ABC"

  # description
  Scenario: Description cannot exceed 1000 characters
    When I fill in "Title" with "Long Description Event"
    And I fill in "Description" with a string of 1001 characters
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Description is too long (maximum is 1000 characters)"

  Scenario: Event can be created without description
    When I fill in "Title" with "No Description Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "No Description Event"

  # location
  Scenario: Location must be at least 3 characters
    When I fill in "Title" with "Short Location Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "AB"
    And I press "Submit"
    Then I should see "Location is too short (minimum is 3 characters)"

  Scenario: Location with exactly 3 characters is valid
    When I fill in "Title" with "Valid Location Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Gym"
    And I press "Submit"
    Then I should see "Valid Location Event"

  # tag
  Scenario: Can create event with no tags
    When I fill in "Title" with "Tagless Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "Tagless Event"

  Scenario: Can create event with multiple tags
    When I fill in "Title" with "Multi-Tag Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I fill in "Tags" with "Tech, Sports, Social"
    And I press "Submit"
    Then I should see "Multi-Tag Event"
    And I should see "Tech"
    And I should see "Sports"
    And I should see "Social"