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

    it 'returns false when user is nil' do
      expect(event.upvoted_by?(nil)).to be false
    end

    it 'handles User objects' do
      Upvote.create!(email: user.email, username: 'testuser', event: event)
      expect(event.upvoted_by?(user)).to be true
    end

    it 'returns false for invalid input types' do
      expect(event.upvoted_by?(123)).to be false
    end
  end

  describe '#toggle_upvote' do
    let(:event) { Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user) }

    it 'returns false when user is nil' do
      expect(event.toggle_upvote(nil)).to be false
    end

    it 'creates an upvote when user has not upvoted' do
      expect {
        event.toggle_upvote(user)
      }.to change { event.upvotes.count }.by(1)
    end

    it 'returns true when creating an upvote' do
      expect(event.toggle_upvote(user)).to be true
    end

    it 'removes an upvote when user has already upvoted' do
      event.upvotes.create!(email: user.email, username: user.name || user.email)
      
      expect {
        event.toggle_upvote(user)
      }.to change { event.upvotes.count }.by(-1)
    end

    it 'returns false when removing an upvote' do
      event.upvotes.create!(email: user.email, username: user.name || user.email)
      expect(event.toggle_upvote(user)).to be false
    end

    it 'uses user name if available' do
      user_with_name = User.create!(
        email: 'named@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        name: 'John Doe'
      )
      
      event.toggle_upvote(user_with_name)
      upvote = event.upvotes.last
      expect(upvote.username).to eq('John Doe')
    end

    it 'uses email as username if name is not available' do
      event.toggle_upvote(user)
      upvote = event.upvotes.last
      expect(upvote.username).to eq(user.email)
    end
  end

  describe '#tags' do
    let(:event) { Event.create!(title: 'Test', date: Date.today, start_time: '18:00', user: user) }

    it 'returns empty array when tags is nil' do
      event.update_column(:tags, nil)
      expect(event.tags).to eq([])
    end

    it 'returns tags array when tags exist' do
      event.update(tags: ['sports', 'outdoor'])
      expect(event.tags).to eq(['sports', 'outdoor'])
    end
  end

  describe '#tags=' do
    let(:event) { Event.new(title: 'Test', date: Date.today, start_time: '18:00', user: user) }

    it 'handles string input with commas' do
      event.tags = 'sports, outdoor, fun'
      expect(event.tags).to eq(['sports', 'outdoor', 'fun'])
    end

    it 'strips whitespace from string tags' do
      event.tags = '  sports  ,  outdoor  '
      expect(event.tags).to eq(['sports', 'outdoor'])
    end

    it 'handles array input' do
      event.tags = ['sports', 'outdoor']
      expect(event.tags).to eq(['sports', 'outdoor'])
    end

    it 'removes blank values from arrays' do
      event.tags = ['sports', '', 'outdoor', nil]
      expect(event.tags).to eq(['sports', 'outdoor'])
    end

    it 'handles non-string, non-array input' do
      event.tags = 123
      expect(event.tags).to eq([])
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