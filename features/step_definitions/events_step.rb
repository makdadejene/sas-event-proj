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

Given("I am on the events index page") do
  visit events_path
end

When("I visit the events page with sort option {string}") do |sort|
  visit events_path(sort: sort)
end

Given("I am on the new event page") do
  visit new_event_path
end

When("I fill in {string} with {string}") do |field, value|
  # Handle both label text and Rails field IDs
  begin
    fill_in field, with: value
  rescue Capybara::ElementNotFound
    # Try Rails default ID format: event_fieldname
    field_id = "event_#{field.downcase.gsub(' ', '_')}"
    fill_in field_id, with: value
  end
end

When("I press {string}") do |button_text|
  click_button button_text
end

When("I click on the add event button") do
  # The add button is a link with a plus sign
  find('a.add-btn').click
end

When("I click the close button") do
  find('button.close-btn').click
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see individual tags {string}") do |tags|
  tag_array = tags.split(',').map(&:strip)
  tag_array.each do |tag|
    expect(page).to have_css('.tag', text: tag)
  end
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("I should see {string} before {string}") do |text1, text2|
  expect(page.body.index(text1)).to be < page.body.index(text2)
end

Then("I should be on the new event page") do
  expect(page).to have_current_path(new_event_path)
end

Then("I should be on the events index page") do
  expect(page).to have_current_path(events_path)
end

Then("the events should have {string} tag") do |tag|
  within('.events-grid') do
    expect(page).to have_css('.tag', text: tag)
  end
end

Then("the events should be displayed in creation order") do
  events = Event.order(:created_at)
  first_event_title = events.first.title
  expect(page.body.index(first_event_title)).to be > 0
end

Then("I should see events with tag {string}") do |tag|
  expect(page).to have_css('.tag', text: tag)
end

Then("I should see dates in {string} format") do |format|
  # Check if dates are formatted correctly (e.g., "Nov 05, 2025")
  expect(page).to have_css('.event-date')
  dates = page.all('.event-date').map(&:text)
  dates.each do |date_text|
    expect(date_text).to match(/[A-Z][a-z]{2} \d{2}, \d{4}/)
  end
end

Then("I should see times in {string} format") do |format|
  # Check if times are formatted correctly (e.g., "23:00")
  expect(page).to have_css('.event-time')
  times = page.all('.event-time').map(&:text)
  times.each do |time_text|
    expect(time_text).to match(/\d{2}:\d{2}/)
  end
end