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
      location: row['location'] || 'Default Location',
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

When('I fill in {string} with {string}') do |field, value|
  case field
  when "Time"
    fill_in "Start Time", with: value
  when "Tags"
    tags = value.split(',').map(&:strip).map(&:downcase)
    tags.each do |tag|
      tag_id = "tag_#{tag.gsub(' ', '_')}"
      check tag_id
    end
  when "Username", "Email Address"
    within('.modal.show', visible: true) do
      fill_in field, with: value
    end
  when "Title"
    fill_in "event_title", with: value
  when "Description"
    fill_in "event_description", with: value
  when "Date"
    fill_in "event_date", with: value
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
  
  # Try different possible selectors for the add button
  begin
    click_link_or_button '+'
  rescue Capybara::ElementNotFound
    begin
      click_link 'Create New Event'
    rescue Capybara::ElementNotFound
      click_link 'New Event'
    end
  end
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