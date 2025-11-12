# spec/models/event_spec.rb
require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { Event.create!(title: 'Test Event', description: 'Test', date: Date.today, time: '12:00', location: 'Test Location') }

  describe 'associations' do
    it { should have_many(:upvotes).dependent(:destroy) }
  end

  describe '#upvote_count' do
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
      event1 = Event.create!(title: 'Event 1', description: 'Test', date: Date.today, time: '12:00', location: 'Test')
      event2 = Event.create!(title: 'Event 2', description: 'Test', date: Date.today, time: '13:00', location: 'Test')
      event3 = Event.create!(title: 'Event 3', description: 'Test', date: Date.today, time: '14:00', location: 'Test')

      # Give event2 the most upvotes
      5.times { |i| Upvote.create!(email: "user#{i}@test.com", username: "user#{i}", event: event2) }
      # Give event3 medium upvotes
      3.times { |i| Upvote.create!(email: "user#{i}@test2.com", username: "user#{i}", event: event3) }
      # Give event1 least upvotes
      1.times { |i| Upvote.create!(email: "user#{i}@test3.com", username: "user#{i}", event: event1) }

      sorted = Event.sorted_by_upvotes
      expect(sorted.first).to eq(event2)
      expect(sorted.second).to eq(event3)
      expect(sorted.third).to eq(event1)
    end

    it 'handles events with no upvotes' do
      event_with_upvotes = Event.create!(title: 'Popular', description: 'Test', date: Date.today, time: '12:00', location: 'Test')
      event_no_upvotes = Event.create!(title: 'Unpopular', description: 'Test', date: Date.today, time: '13:00', location: 'Test')
      
      Upvote.create!(email: 'test@example.com', username: 'testuser', event: event_with_upvotes)
      
      sorted = Event.sorted_by_upvotes
      expect(sorted.first).to eq(event_with_upvotes)
      expect(sorted.last).to eq(event_no_upvotes)
    end
  end
end