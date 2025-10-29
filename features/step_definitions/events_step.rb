# features/step_definitions/events_step.rb

Given("the following events exist:") do |events_table|
  events_table.hashes.each do |event|
    Event.create!(
      title: event['title'],
      description: event['description'],
      date: event['date'],
      time: event['time'],
      tags: event['tags']
    )
  end
end

When("I visit the events index page") do
  visit events_path
end

When("I visit the events page with sort option {string}") do |sort|
  visit events_path(sort: sort)
end

Given("I am on the new event page") do
  visit new_event_path
end

When("I fill in {string} with {string}") do |field, value|
  # Try to find by label text first, then by Rails default ID
  begin
    fill_in field, with: value
  rescue Capybara::ElementNotFound
    # Rails default ID: event_fieldname (e.g., event_title)
    fill_in "event_#{field.downcase}", with: value
  end
end

When("I press {string}") do |button_text|
  click_button button_text
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see {string} before {string}") do |text1, text2|
  expect(page.body.index(text1)).to be < page.body.index(text2)
end
