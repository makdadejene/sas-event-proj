# features/step_definitions/upvote_steps.rb
Given('I have upvoted {string} with email {string}') do |event_title, email|
  event = Event.find_by(title: event_title)
  Upvote.create!(event: event, email: email, username: 'testuser')
end

When('I click the upvote button for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  @current_upvote_event = event  # Store for next steps
end

When('I upvote {string} with username {string} and email {string}') do |event_title, username, email|
  event = Event.find_by(title: event_title)
  
  page.driver.post "/events/#{event.id}/upvotes", 
    upvote: { username: username, email: email }
end

Then('the upvote count for {string} should be {string}') do |event_title, count|
  event = Event.find_by(title: event_title)
  visit events_path # Refresh to see updated count
  
  within(".upvote-container[data-event-id='#{event.id}']") do
    expect(find('.upvote-count').text).to eq(count)
  end
end

Given('{string} has {int} upvotes') do |event_title, count|
  event = Event.find_by(title: event_title)
  count.times do |i|
    Upvote.create!(
      event: event,
      email: "user#{i}_#{event.id}@example.com",
      username: "user#{i}"
    )
  end
end

When('I click on {string}') do |link_text|
  click_link link_text
end

Then('I should see events in this order:') do |table|
  event_titles = table.raw.flatten
  page_text = page.body
  
  positions = event_titles.map do |title|
    pos = page_text.index(title)
    raise "Could not find '#{title}' on page" if pos.nil?
    pos
  end
  
  # Check that positions are in ascending order
  positions.each_cons(2) do |pos1, pos2|
    expect(pos1).to be < pos2, "Expected events in order: #{event_titles.join(', ')}"
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