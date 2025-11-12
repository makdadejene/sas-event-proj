Feature: Upvote Events
  As a student
  I want to upvote events I'm interested in
  So that popular events are more visible

  Background:
    Given the following events exist:
      | title           | description        | date       | time  | location      | tags    |
      | Tech Talk       | AI Workshop        | 2025-12-01 | 14:00 | CS Building   | Tech    |
      | Career Fair     | Job Opportunities  | 2025-12-05 | 10:00 | Student Union | Career  |
      | Music Concert   | Live Performance   | 2025-12-10 | 19:00 | Auditorium    | Social  |

  Scenario: Student upvotes an event
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Student cannot upvote the same event twice
    Given I have upvoted "Tech Talk" with email "john@example.com"
    And I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Student can upvote multiple different events
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@example.com"
    And I upvote "Career Fair" with username "john_doe" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"
    And the upvote count for "Career Fair" should be "1"

  Scenario: Invalid email format is rejected
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "invalid-email"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Username too short is rejected
    Given I visit the events index page
    When I upvote "Tech Talk" with username "j" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Events sorted by upvotes show most popular first
    Given "Tech Talk" has 5 upvotes
    And "Career Fair" has 2 upvotes
    And "Music Concert" has 8 upvotes
    When I am on the events page
    And I click on "Most Upvoted"
    Then I should see events in this order:
      | Music Concert |
      | Tech Talk     |
      | Career Fair   |

  Scenario: Rate limiting prevents spam upvoting
    Given I have upvoted 10 events in the last hour with email "spam@example.com"
    And I visit the events index page
    When I upvote "Music Concert" with username "spammer" and email "spam@example.com"
    Then the upvote count for "Music Concert" should be "0"

  Scenario: Upvote count displays correctly
    Given "Tech Talk" has 0 upvotes
    When I visit the events index page
    Then the upvote count for "Tech Talk" should be "0"
    When I upvote "Tech Talk" with username "user1" and email "user1@example.com"
    And I visit the events index page
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Multiple students can upvote the same event
    Given I visit the events index page
    When I upvote "Tech Talk" with username "user1" and email "user1@example.com"
    And I upvote "Tech Talk" with username "user2" and email "user2@example.com"
    And I upvote "Tech Talk" with username "user3" and email "user3@example.com"
    Then the upvote count for "Tech Talk" should be "3"