# features/step_definitions/upvote_steps.rb

When('I upvote {string} with username {string} and email {string}') do |event_title, username, email|
  event = Event.find_by(title: event_title)
  
  # Remove the manual rate limit check - let the model validations handle it
  Upvote.create(
    event: event,
    username: username,
    email: email
  )
end

Then('the upvote count for {string} should be {string}') do |event_title, expected_count|
  event = Event.find_by(title: event_title)
  
  # Check the actual count from upvotes association
  actual_count = event.upvotes.count
  expect(actual_count).to eq(expected_count.to_i)
end

Given('I have upvoted {string} with email {string}') do |event_title, email|
  event = Event.find_by(title: event_title)
  Upvote.create!(
    event: event,
    username: "test_user",
    email: email
  )
end

Given('{string} has {int} upvotes') do |event_title, upvote_count|
  event = Event.find_by(title: event_title)
  upvote_count.times do |i|
    Upvote.create!(
      event: event,
      username: "user#{i}",
      email: "user#{i}@example.com"
    )
  end
end

When('I click on {string}') do |link_text|
  case link_text
  when "Most Upvoted"
    visit events_path(sort: 'upvotes')
  else
    click_link link_text
  end
end

Then('I should see events in this order:') do |table|
  event_titles = table.raw.flatten
  
  # Get all event titles from the page in order
  page_titles = all('.event-card .event-title').map(&:text)
  
  event_titles.each_with_index do |expected_title, index|
    expect(page_titles[index]).to eq(expected_title)
  end
end

Given('I have upvoted {int} events in the last hour with email {string}') do |count, email|
  count.times do |i|
    event = Event.create!(
      title: "Spam Event #{i}",
      description: "Test event #{i}",
      date: Date.today,
      start_time: "12:00",
      location: "Test Location",
      tags: ["Test"],
      user: @test_user
    )
    Upvote.create!(event: event, email: email, username: 'testuser')
  end
end

Given('I am on the events page') do
  visit events_path
end