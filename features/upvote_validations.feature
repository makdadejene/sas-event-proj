# features/upvote_validations.feature
Feature: Upvote Validation Rules
  As a student
  I want upvote restrictions to be enforced
  So that voting is fair and prevents abuse

  Background:
    Given the following events exist:
      | title       | description    | date       | time  | location      | tags  |
      | Tech Talk   | AI Workshop    | 2026-01-15 | 14:00 | CS Building   | Tech  |
      | Career Fair | Job Opportunities | 2026-01-20 | 10:00 | Student Union | Career |

  # EMAIL VALIDATIONS
  Scenario: Cannot upvote with invalid email format
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "notanemail"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Cannot upvote with email missing @
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "johngmail.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Cannot upvote with email missing domain
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Cannot upvote with empty email
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email ""
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Valid email formats are accepted
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john.doe@university.edu"
    Then the upvote count for "Tech Talk" should be "1"

  # USERNAME VALIDATIONS
  Scenario: Cannot upvote with username shorter than 2 characters
    Given I visit the events index page
    When I upvote "Tech Talk" with username "a" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Cannot upvote with username longer than 50 characters
    Given I visit the events index page
    When I upvote "Tech Talk" with username "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Cannot upvote with empty username
    Given I visit the events index page
    When I upvote "Tech Talk" with username "" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Username can contain underscores and numbers
    Given I visit the events index page
    When I upvote "Tech Talk" with username "user_123" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Username with exactly 2 characters is valid
    Given I visit the events index page
    When I upvote "Tech Talk" with username "ab" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  # DUPLICATE PREVENTION
  Scenario: Cannot upvote same event twice with same email
    Given I have upvoted "Tech Talk" with email "john@example.com"
    And I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Cannot upvote same event twice with same email but different username
    Given I have upvoted "Tech Talk" with email "john@example.com"
    And I visit the events index page
    When I upvote "Tech Talk" with username "different_user" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Can upvote different events with same email
    Given I visit the events index page
    When I upvote "Tech Talk" with username "john_doe" and email "john@example.com"
    And I upvote "Career Fair" with username "john_doe" and email "john@example.com"
    Then the upvote count for "Tech Talk" should be "1"
    And the upvote count for "Career Fair" should be "1"

  Scenario: Different users can upvote the same event
    Given I visit the events index page
    When I upvote "Tech Talk" with username "user1" and email "user1@example.com"
    And I upvote "Tech Talk" with username "user2" and email "user2@example.com"
    And I upvote "Tech Talk" with username "user3" and email "user3@example.com"
    Then the upvote count for "Tech Talk" should be "3"

  # RATE LIMITING
  Scenario: Rate limit allows up to 10 upvotes per hour
    Given I have upvoted 10 events in the last hour with email "active@example.com"
    And I visit the events index page
    When I upvote "Tech Talk" with username "active_user" and email "active@example.com"
    Then the upvote count for "Tech Talk" should be "0"

  Scenario: Rate limit is per email address
    Given I have upvoted 10 events in the last hour with email "user1@example.com"
    And I visit the events index page
    When I upvote "Tech Talk" with username "user2" and email "user2@example.com"
    Then the upvote count for "Tech Talk" should be "1"

  Scenario: Can upvote 10 events in one hour without issue
    Given I visit the events index page
    When I upvote 9 different events with email "normal@example.com"
    And I upvote "Tech Talk" with username "normal_user" and email "normal@example.com"
    Then the upvote count for "Tech Talk" should be "1"