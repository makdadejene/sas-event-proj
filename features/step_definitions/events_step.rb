# features/step_definitions/events_step.rb

Given('the following events exist:') do |table|
  # Create a default test user for OAuth
  @test_user = User.find_or_create_by!(email: 'test@example.com') do |user|
    user.provider = 'google_oauth2'
    user.uid = '123545'
    user.name = 'Test User' if user.respond_to?(:name=)
  end

  table.hashes.each do |row|
    Event.create!(
      title: row['title'],
      description: row['description'],
      date: row['date'],
      start_time: row['time'],
      tags: row['tags']&.split(',')&.map(&:strip) || [],
      location: row['location'],
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

Given('I am on the new event page') do
  @test_user = User.find_or_create_by!(email: 'test@example.com') do |user|
    user.provider = 'google_oauth2'
    user.uid = '123545'
    user.name = 'Test User' if user.respond_to?(:name=)
  end
  
  allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@test_user)
  
  visit new_event_path
end

# Update your fill_in step:
When('I fill in {string} with {string}') do |field, value|
  if field == "Time"
    fill_in "Start Time", with: value
  elsif field == "Tags"
    tags = value.split(',').map(&:strip).map(&:downcase)
    tags.each do |tag|
      check "tag_#{tag}"
    end
  elsif field == "Username" || field == "Email Address"
    within('.modal.show', visible: true) do
      fill_in field, with: value
    end
  else
    fill_in field, with: value
  end
end

When('I press {string}') do |button|
  click_button button
end

When('I click on the add event button') do
  # Bypass auth before clicking
  @test_user = User.find_or_create_by!(email: 'test@example.com') do |user|
    user.provider = 'google_oauth2'
    user.uid = '123545'
    user.name = 'Test User'
  end
  
  allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@test_user)
  
  click_link_or_button '+'
end
Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should see {string} before {string}') do |first_text, second_text|
  page_text = page.body
  first_position = page_text.index(first_text)
  second_position = page_text.index(second_text)
  
  expect(first_position).not_to be_nil, "Expected to find '#{first_text}' on the page"
  expect(second_position).not_to be_nil, "Expected to find '#{second_text}' on the page"
  expect(first_position).to be < second_position, 
    "Expected '#{first_text}' to appear before '#{second_text}'"
end

Then('I should be on the new event page') do
  expect(current_path).to eq(new_event_path)
end

Then('I should be on the events index page') do
  expect(current_path).to eq(events_path)
end