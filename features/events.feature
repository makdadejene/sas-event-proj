Feature: Browse and add events
  As a student
  I want to browse and add events
  So that I can see what events are available and create new ones

  Background: events exist in the database
    Given the following events exist:
      | title                     | description                                                                                 | date       | time  | tags           |
      | Midnight Movie Marathon    | Snacks, comfy seats, and back-to-back movies all night long in the Student Lounge.         | 2025-11-05 | 23:00 | Club, Social   |
      | Campus Soccer Pickup Game  | Come kick around with fellow students on the North Field! No experience needed, just fun vibes. | 2025-11-06 | 16:00 | Sports, Other  |
      | Student Potluck Dinner     | Bring your favorite dish and sample treats from everyone else in the Dorm Lounge.          | 2025-11-08 | 18:30 | Cultural, Other|

  Scenario: Browse all events
    When I visit the events index page
    Then I should see "Midnight Movie Marathon"
    And I should see "Campus Soccer Pickup Game"
    And I should see "Student Potluck Dinner"

  Scenario: Add a new event
    Given I am on the new event page
    When I fill in "Title" with "K-Pop Dance Practice"
    And I fill in "Description" with "Join our dance club in Dance Studio 2 to learn popular K-Pop routines—fun, energetic, and no pressure!"
    And I fill in "Date" with "2025-11-10"
    And I fill in "Time" with "19:00"
    And I fill in "Tags" with "Club, Cultural"
    And I press "Submit"
    Then I should see "K-Pop Dance Practice"

  Scenario: Browse events sorted alphabetically
    When I visit the events page with sort option "alphabetical"
    Then I should see "Campus Soccer Pickup Game" before "Midnight Movie Marathon"
    And I should see "Midnight Movie Marathon" before "Student Potluck Dinner"
