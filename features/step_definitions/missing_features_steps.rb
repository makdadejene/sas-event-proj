# features/step_definitions/missing_features_steps.rb

# EDIT EVENTS
Given('I am the creator of {string}') do |event_title|
  event = Event.find_by(title: event_title)
  @test_user = event.user
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@test_user)
end

When('I visit the edit page for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  visit edit_event_path(event)
end

# DELETE EVENTS
When('I click delete for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  within("#event_#{event.id}") do
    click_link 'Delete'
  end
end

# IMAGE UPLOADS
When('I attach a valid image') do
  attach_file('event[image]', Rails.root.join('spec/fixtures/files/test.jpg'))
end

When('I attach a PDF file') do
  attach_file('event[image]', Rails.root.join('spec/fixtures/files/test.pdf'))
end

# PRIVATE EVENTS
When('I check {string}') do |checkbox|
  check checkbox
end

Given('I create a private event {string}') do |title|
  Event.create!(
    title: title,
    date: Date.today + 1.day,
    start_time: '14:00',
    location: 'Test Location',
    private: true,
    user: @test_user
  )
end

When('I log out') do
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

# FILTER BY TAGS
When('I click on tag {string}') do |tag|
  click_link tag
end