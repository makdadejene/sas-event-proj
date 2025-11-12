require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      event = Event.new(title: 'Test', date: Date.today, start_time: '18:00', user: user)
      expect(event).to be_valid
    end

    it 'is invalid without a title' do
      event = Event.new(title: nil, date: Date.today, start_time: '18:00', user: user)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a date' do
      event = Event.new(title: 'Test', date: nil, start_time: '18:00', user: user)
      expect(event).not_to be_valid
      expect(event.errors[:date]).to include("can't be blank")
    end

    it 'is invalid without a start_time' do
      event = Event.new(title: 'Test', date: Date.today, start_time: nil, user: user)
      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many upvotes' do
      event = Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user)
      expect(event).to respond_to(:upvotes)
    end

    it 'belongs to user' do
      event = Event.new(title: 'Test', date: Date.today, start_time: '18:00')
      expect(event).to respond_to(:user)
    end

    it 'destroys associated upvotes when destroyed' do
      event = Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user)
      upvote = event.upvotes.create!(email: 'test@example.com', username: 'testuser')
      
      expect { event.destroy }.to change { Upvote.count }.by(-1)
    end
  end

  describe '#upvote_count' do
    let(:event) { Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user) }

    it 'returns 0 when no upvotes' do
      expect(event.upvote_count).to eq(0)
    end

    it 'returns correct count with upvotes' do
      3.times do |i|
        Upvote.create!(email: "user#{i}@example.com", username: "user#{i}", event: event)
      end
      expect(event.upvote_count).to eq(3)
    end
  end

  describe '#upvoted_by?' do
    let(:event) { Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user) }

    it 'returns false when email has not upvoted' do
      expect(event.upvoted_by?('test@example.com')).to be false
    end

    it 'returns true when email has upvoted' do
      Upvote.create!(email: 'test@example.com', username: 'testuser', event: event)
      expect(event.upvoted_by?('test@example.com')).to be true
    end

    it 'is case insensitive' do
      Upvote.create!(email: 'test@example.com', username: 'testuser', event: event)
      expect(event.upvoted_by?('TEST@EXAMPLE.COM')).to be true
    end
  end

  describe '.sorted_by_upvotes' do
    it 'sorts events by upvote count in descending order' do
      event1 = Event.create!(title: 'Event 1', date: Date.today, start_time: '18:00', user: user)
      event2 = Event.create!(title: 'Event 2', date: Date.today, start_time: '19:00', user: user)
      event3 = Event.create!(title: 'Event 3', date: Date.today, start_time: '20:00', user: user)

      # event2 gets 3 upvotes
      3.times { |i| Upvote.create!(email: "user#{i}@example.com", username: "user#{i}", event: event2) }
      # event1 gets 1 upvote
      Upvote.create!(email: 'single@example.com', username: 'single', event: event1)
      # event3 gets 0 upvotes

      sorted = Event.sorted_by_upvotes
      expect(sorted.map(&:id)).to eq([event2.id, event1.id, event3.id])
    end

    it 'handles events with no upvotes' do
      event1 = Event.create!(title: 'Event 1', date: Date.today, start_time: '18:00', user: user)
      event2 = Event.create!(title: 'Event 2', date: Date.today, start_time: '19:00', user: user)

      sorted = Event.sorted_by_upvotes
      expect(sorted).to include(event1, event2)
    end
  end
end