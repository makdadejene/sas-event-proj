# features/step_definitions/events_step.rb


def ensure_logged_in
  unless @logged_in
    @test_user ||= User.find_or_create_by!(
      email: 'test@example.com',
      provider: 'google_oauth2',
      uid: '12345'
    )
    
    # Log in using Warden (Devise's authentication)
    login_as(@test_user, scope: :user)
    @logged_in = true
  end
end

Given('the following events exist:') do |table|
  ensure_logged_in
  table.hashes.each do |event|
    Event.create!(
      title: event['title'],
      description: event['description'],
      date: event['date'],
      start_time: event['time'],
      location: event['location'],
      tags: event['tags'].split(',').map(&:strip),
      user: @test_user
    )
  end
end

When('I visit the events index page') do
  visit events_path
end

When('I visit the events page with sort option {string}') do |sort_option|
  visit events_path(sort: sort_option)
end

When('I am on the new event page') do
  ensure_logged_in
  visit new_event_path
end

When('I fill in {string} with {string}') do |field, value|
  # Special handling for Tags - they're checkboxes not a text field
  if field == 'Tags'
    tags = value.split(',').map(&:strip)
    tags.each do |tag|
      check("tag_#{tag.downcase}")
    end
    next
  end
  
  field_id = case field
  when 'Title' then 'event_title'
  when 'Description' then 'event_description'
  when 'Date' then 'event_date'
  when 'Time', 'Start Time' then 'event_start_time'
  when 'End Time' then 'event_end_time'
  when 'Location' then 'event_location'
  else
    begin
      fill_in field, with: value
      next
    rescue Capybara::ElementNotFound
      field.downcase.gsub(' ', '_')
    end
  end
  
  fill_in field_id, with: value
end

# Field checking step
Then('the {string} field should contain {string}') do |field, value|
  field_id = case field
  when 'Title' then 'event_title'
  when 'Description' then 'event_description'
  when 'Date' then 'event_date'
  when 'Start Time' then 'event_start_time'
  when 'End Time' then 'event_end_time'
  when 'Location' then 'event_location'
  when 'Tags' then 'event_tags'
  else field.downcase.gsub(' ', '_')
  end
  
  begin
    field_element = find_field(field_id)
  rescue Capybara::ElementNotFound
    field_element = find_field(field)
  end
  
  expect(field_element.value).to eq(value)
end

When('I press {string}') do |button|
  click_button button
end

When('I click on the add event button') do
  find('.add-btn').click  
end

# Assertion steps
Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should see {string} before {string}') do |first_text, second_text|
  expect(page.body.index(first_text)).to be < page.body.index(second_text)
end

Then('I should be on the events index page') do
  expect(current_path).to eq(events_path)
end

Then('I should be on the new event page') do
  sleep 0.1
  expect(page).to have_button('Submit')
  expect(page).to have_field('Title')
end