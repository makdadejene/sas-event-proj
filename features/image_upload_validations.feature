# features/image_upload_validations.feature
Feature: Image Upload Restrictions
  As a student
  I want only valid images to be uploaded
  So that the site displays properly

  Background:
    Given I am on the new event page

  Scenario: Can upload valid JPEG image
    When I fill in "Title" with "Image Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I attach a valid JPEG image
    And I press "Submit"
    Then I should see "Image Event"
    And I should see the uploaded image

  Scenario: Can upload valid PNG image
    When I fill in "Title" with "PNG Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I attach a valid PNG image
    And I press "Submit"
    Then I should see "PNG Event"
    And I should see the uploaded image

  Scenario: Cannot upload PDF file as image
    When I fill in "Title" with "PDF Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I attach a PDF file
    And I press "Submit"
    Then I should see "Image must be a valid image file"

  Scenario: Cannot upload file larger than 5MB
    When I fill in "Title" with "Large Image Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I attach an image larger than 5MB
    And I press "Submit"
    Then I should see "Image file size must be less than 5MB"

  Scenario: Can create event without image
    When I fill in "Title" with "No Image Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I press "Submit"
    Then I should see "No Image Event"

  Scenario: Cannot upload text file as image
    When I fill in "Title" with "Text File Event"
    And I fill in "Date" with "2025-12-20"
    And I fill in "Time" with "14:00"
    And I fill in "Location" with "Campus Hall"
    And I attach a text file
    And I press "Submit"
    Then I should see "Image must be a valid image file"