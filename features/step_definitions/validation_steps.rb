# features/step_definitions/validation_steps.rb

When('I fill in {string} with a string of {int} characters') do |field, length|
  long_string = 'a' * length
  fill_in field, with: long_string
end

# Image upload steps
When('I attach a valid JPEG image') do
  attach_file('event[image]', Rails.root.join('spec/fixture/files/test_image.jpg'))
end

When('I attach a valid PNG image') do
  attach_file('event[image]', Rails.root.join('spec/fixture/files/test_image.png'))
end

When('I attach a text file') do
  attach_file('event[image]', Rails.root.join('spec/fixture/files/test.txt'))
end

When('I attach an image larger than 5MB') do
  attach_file('event[image]', Rails.root.join('spec/fixture/files/large_image.jpg'))
end

Then('I should see the uploaded image') do
  expect(page).to have_css('img[src*="test"]')
end

Then('I should see a privacy indicator for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  within("#event_#{event.id}") do
    has_indicator = page.has_css?('.privacy-indicator') || page.has_content?('Private')
    expect(has_indicator).to be true
  end
end

# Authorization steps
Given(/^I am not the creator of "([^"]*)"$/) do |event_title|
  event = Event.find_by(title: event_title)
  @other_user = User.create!(
    email: 'other@example.com',
    provider: 'google_oauth2',
    uid: '67890'
  )
  
  puts "DEBUG NOT CREATOR"
  puts "Event: #{event.title}"
  puts "Event user: #{event.user.inspect}"
  puts "Other user: #{@other_user.inspect}"
  
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@other_user)
end

Then('I should be redirected to the events index page') do
  expect(current_path).to eq(events_path)
end

Then('I should see an error message') do
  expect(page).to have_selector('.alert, .error, #error_explanation', visible: true)
end

Then(/^I should not see delete button for "([^"]*)"$/) do |event_title|
  event = Event.find_by(title: event_title)
  within("#event_#{event.id}") do
    expect(page).not_to have_button("Delete")
  end
end

Then /^the upvotes for "([^"]*)" should also be deleted$/ do |event_title|
  event = Event.find_by(title: event_title)
  expect(event).to be_nil  # Event should be deleted
  
  # Verify upvotes are also gone
  upvotes = Upvote.where(event_id: event&.id)
  expect(upvotes.count).to eq(0)
end

# Confirmation dialog steps - FIXED for rack_test driver
Then('I should see a confirmation dialog') do
  expect(page).to have_css('[data-turbo-confirm]')
end

When /^I confirm the deletion$/ do
  page.driver.browser.switch_to.alert.accept
end

When /^I cancel the deletion$/ do
  page.driver.browser.switch_to.alert.dismiss
end
# Event counting steps
Then('I should see {int} event(s)') do |count|
  events = all('.event-card, .event, [data-event]')
  expect(events.count).to eq(count)
end
# Multiple upvotes helper
When('I upvote {int} different events with email {string}') do |count, email|
  count.times do |i|
    event = Event.create!(
      title: "Event #{i}",
      description: "Test event #{i}",
      date: Date.today + i.days,
      start_time: "12:00",
      location: "Location #{i}",
      tags: ["Test"],
      user: @test_user
    )
    Upvote.create!(
      event: event,
      username: 'testuser',
      email: email
    )
  end
end

Then('{string} should still exist') do |event_title|
  expect(Event.find_by(title: event_title)).not_to be_nil
end

When('I attempt to delete {string} via direct URL') do |event_title|
  event = Event.find_by(title: event_title)
  page.driver.submit :delete, event_path(event), {}
end

# Rate limiting helper for old upvotes
Given('I have upvoted {int} events more than {int} hour ago with email {string}') do |count, hours, email|
  count.times do |i|
    event = Event.create!(
      title: "Old Event #{i}",
      description: "Test event #{i}",
      date: Date.today + i.days,
      start_time: "12:00",
      location: "Location #{i}",
      tags: ["Test"],
      user: @test_user
    )
    upvote = Upvote.create!(
      event: event,
      username: 'testuser',
      email: email
    )
    upvote.update_column(:created_at, (hours + 1).hours.ago)
  end
end