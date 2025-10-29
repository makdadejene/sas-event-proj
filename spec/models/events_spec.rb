# spec/models/event_spec.rb
require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      event = Event.new(
        title: "Test Event",
        date: Date.today,
        time: Time.now,
        tags: "Sports"
      )
      expect(event).to be_valid
    end

    it "is not valid without a title" do
      event = Event.new(title: nil, date: Date.today, time: Time.now)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a date" do
      event = Event.new(title: "Test", date: nil, time: Time.now)
      expect(event).not_to be_valid
      expect(event.errors[:date]).to include("can't be blank")
    end

    it "is not valid without a time" do
      event = Event.new(title: "Test", date: Date.today, time: nil)
      expect(event).not_to be_valid
      expect(event.errors[:time]).to include("can't be blank")
    end

    it "allows blank description" do
      event = Event.new(
        title: "Test",
        date: Date.today,
        time: Time.now,
        description: nil
      )
      expect(event).to be_valid
    end

    it "allows blank tags" do
      event = Event.new(
        title: "Test",
        date: Date.today,
        time: Time.now,
        tags: nil
      )
      expect(event).to be_valid
    end
  end

  describe "database columns" do
    it "has the expected columns" do
      expect(Event.column_names).to include("title", "date", "time", "description", "tags")
    end
  end

  describe "creating events" do
    it "saves with all attributes" do
      event = Event.create!(
        title: "Full Event",
        date: Date.today,
        time: Time.now,
        description: "A full description",
        tags: "Sports, Social"
      )
      
      expect(event.persisted?).to be true
      expect(event.title).to eq("Full Event")
      expect(event.description).to eq("A full description")
      expect(event.tags).to eq("Sports, Social")
    end
  end
end