# features/step_definitions/missing_features_steps.rb

Given('I am the creator of {string}') do |event_title|
  event = Event.find_by(title: event_title)
  @test_user = event.user
  
  puts "DEBUG USER SETUP"
  puts "Event: #{event.title}"
  puts "Event user: #{event.user.inspect}"
  puts "Test user: #{@test_user.inspect}"
  
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@test_user)
end

When('I visit the edit page for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  visit edit_event_path(event)
end

When('I click delete for {string}') do |event_title|
  event = Event.find_by(title: event_title)
  
  puts "DEBUG DELETE CLICK"
  puts "Event found: #{event.inspect}"
  puts "Event ID: #{event.id}"
  puts "Looking for: #event_#{event.id}"
  puts "Page HTML around event:"
  puts page.find("#event_#{event.id}").native.to_html
  
  within("#event_#{event.id}") do
    click_link 'Delete'
  end
  
  puts "After clicking delete"
end

When('I attach a PDF file') do
  attach_file('event[image]', Rails.root.join('spec/fixtures/files/test.pdf'))
end

When('I check {string}') do |checkbox|
  check checkbox
end

Given('I create a public event {string} with tags {string}') do |title, tags|
  @test_user ||= User.create!(
    email: 'test@example.com',
    provider: 'google_oauth2',
    uid: '12345'
  )
  
  Event.create!(
    title: title,
    description: 'Public event description',
    date: Date.tomorrow,
    start_time: '14:00',
    end_time: '16:00',
    location: 'Public Location',
    tags: tags.split(',').map(&:strip),
    unlisted: false,  # Public event
    user: @test_user
  )
end

Given('I create a private event {string}') do |title|
  @test_user ||= User.create!(
    email: 'test@example.com',
    provider: 'google_oauth2',
    uid: '12345'
  )
  
  Event.create!(
    title: title,
    description: 'Private event description',
    date: Date.tomorrow,
    start_time: '14:00',
    location: 'Private Location',
    tags: ['Private'],
    unlisted: true,  # ADD THIS LINE!
    user: @test_user
  )
end

Given('I create a private event {string} with tags {string}') do |title, tags|
  @test_user ||= User.create!(
    email: 'test@example.com',
    provider: 'google_oauth2',
    uid: '12345'
  )
  
  Event.create!(
    title: title,
    description: 'Private event description',
    date: Date.tomorrow,
    start_time: '14:00',
    location: 'Private Location',
    tags: tags.split(',').map(&:strip),
    unlisted: true,  # ADD THIS LINE!
    user: @test_user
  )
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end


When('I log out') do
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
  visit events_path
end

When('I click on tag {string}') do |tag_name|
  click_link tag_name
end