# spec/models/event_spec.rb
require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { User.create!(email: 'test@example.com', provider: 'google_oauth2', uid: '12345') }

  describe 'validations' do
    context 'presence validations' do
      it 'is valid with all required attributes' do
        event = Event.new(
          title: 'Test Event',
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).to be_valid
      end

      it 'is invalid without a title' do
        event = Event.new(title: nil, date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:title]).to include("can't be blank")
      end

      it 'is invalid without a date' do
        event = Event.new(title: 'Test', date: nil, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:date]).to include("can't be blank")
      end

      it 'is invalid without a start_time' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: nil, location: 'Test Location', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:start_time]).to include("can't be blank")
      end

      it 'is invalid without a location' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: nil, user: user)
        expect(event).not_to be_valid
        expect(event.errors[:location]).to include("can't be blank")
      end

      it 'is valid without a description' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).to be_valid
      end

      it 'is valid without end_time' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).to be_valid
      end
    end

    context 'length validations' do
      it 'is invalid with title shorter than 3 characters' do
        event = Event.new(title: 'AB', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:title]).to include("is too short (minimum is 3 characters)")
      end

      it 'is valid with title of exactly 3 characters' do
        event = Event.new(title: 'ABC', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).to be_valid
      end

      it 'is invalid with title longer than 100 characters' do
        event = Event.new(title: 'A' * 101, date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:title]).to include("is too long (maximum is 100 characters)")
      end

      it 'is valid with title of exactly 100 characters' do
        event = Event.new(title: 'A' * 100, date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
        expect(event).to be_valid
      end

      it 'is invalid with location shorter than 3 characters' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'AB', user: user)
        expect(event).not_to be_valid
        expect(event.errors[:location]).to include("is too short (minimum is 3 characters)")
      end

      it 'is valid with location of exactly 3 characters' do
        event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'ABC', user: user)
        expect(event).to be_valid
      end

      it 'is invalid with description longer than 1000 characters' do
        event = Event.new(
          title: 'Test',
          description: 'A' * 1001,
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).not_to be_valid
        expect(event.errors[:description]).to include("is too long (maximum is 1000 characters)")
      end

      it 'is valid with description of exactly 1000 characters' do
        event = Event.new(
          title: 'Test',
          description: 'A' * 1000,
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).to be_valid
      end
    end

    context 'date validations' do
      it 'is invalid with past date' do
        event = Event.new(
          title: 'Past Event',
          date: Date.today - 1,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).not_to be_valid
        expect(event.errors[:date]).to include("must be in the future")
      end

      it 'is valid with today\'s date' do
        event = Event.new(
          title: 'Today Event',
          date: Date.today,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).to be_valid
      end

      it 'is valid with future date' do
        event = Event.new(
          title: 'Future Event',
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).to be_valid
      end
    end

    context 'time validations' do
      it 'is invalid when end_time is before start_time' do
        event = Event.new(
          title: 'Bad Times',
          date: Date.today + 1,
          start_time: '18:00',
          end_time: '16:00',
          location: 'Test Location',
          user: user
        )
        expect(event).not_to be_valid
        expect(event.errors[:end_time]).to include("must be after start time")
      end

      it 'is invalid when end_time equals start_time' do
        event = Event.new(
          title: 'Same Times',
          date: Date.today + 1,
          start_time: '18:00',
          end_time: '18:00',
          location: 'Test Location',
          user: user
        )
        expect(event).not_to be_valid
        expect(event.errors[:end_time]).to include("must be after start time")
      end

      it 'is valid when end_time is after start_time' do
        event = Event.new(
          title: 'Good Times',
          date: Date.today + 1,
          start_time: '18:00',
          end_time: '20:00',
          location: 'Test Location',
          user: user
        )
        expect(event).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      event = Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location')
      expect(event).to respond_to(:user)
    end

    it 'has many upvotes' do
      event = Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
      expect(event).to respond_to(:upvotes)
    end

    it 'destroys dependent upvotes when destroyed' do
      event = Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
      upvote = event.upvotes.create!(email: 'test@example.com', username: 'testuser')
      
      expect { event.destroy }.to change { Upvote.count }.by(-1)
    end

    it 'can have multiple upvotes' do
      event = Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user)
      3.times { |i| event.upvotes.create!(email: "user#{i}@example.com", username: "user#{i}") }
      
      expect(event.upvotes.count).to eq(3)
    end
  end

  describe '#upvote_count' do
    let(:event) { Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

    it 'returns 0 when no upvotes' do
      expect(event.upvote_count).to eq(0)
    end

    it 'returns correct count with upvotes' do
      3.times do |i|
        Upvote.create!(email: "user#{i}@example.com", username: "user#{i}", event: event)
      end
      expect(event.upvote_count).to eq(3)
    end

    it 'updates count when upvote is added' do
      expect {
        event.upvotes.create!(email: 'new@example.com', username: 'new')
      }.to change { event.upvote_count }.by(1)
    end

    it 'updates count when upvote is removed' do
      upvote = event.upvotes.create!(email: 'test@example.com', username: 'test')
      expect {
        upvote.destroy
      }.to change { event.upvote_count }.by(-1)
    end
  end

  describe '#upvoted_by?' do
    let(:event) { Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

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

    it 'returns false for User objects without upvote' do
      expect(event.upvoted_by?(user)).to be false
    end

    it 'returns false for invalid input types' do
      expect(event.upvoted_by?(123)).to be false
      expect(event.upvoted_by?([])).to be false
    end
  end

  describe '#toggle_upvote' do
    let(:event) { Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

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
        provider: 'google_oauth2',
        uid: '99999',
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

    it 'is case insensitive when finding existing upvote' do
      Upvote.create!(email: user.email.downcase, username: user.email, event: event)
      
      expect {
        event.toggle_upvote(user)
      }.to change { event.upvotes.count }.by(-1)
    end
  end

  describe '#tags' do
    let(:event) { Event.create!(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

    it 'returns empty array when tags is nil' do
      event.update_column(:tags, nil)
      expect(event.tags).to eq([])
    end

    it 'returns tags array when tags exist' do
      event.update(tags: ['sports', 'outdoor'])
      expect(event.tags).to eq(['sports', 'outdoor'])
    end

    it 'handles single tag' do
      event.update(tags: ['tech'])
      expect(event.tags).to eq(['tech'])
    end
  end

  describe '#tags=' do
    let(:event) { Event.new(title: 'Test', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

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

    it 'handles nil input' do
      event.tags = nil
      expect(event.tags).to eq([])
    end

    it 'handles empty string' do
      event.tags = ''
      expect(event.tags).to eq([])
    end
  end

  describe '.sorted_by_upvotes' do
    before { Event.destroy_all }

    it 'sorts events by upvote count in descending order' do
      event1 = Event.create!(title: 'Event 1', date: Date.today + 1, start_time: '18:00', location: 'Location 1', user: user)
      event2 = Event.create!(title: 'Event 2', date: Date.today + 1, start_time: '19:00', location: 'Location 2', user: user)
      event3 = Event.create!(title: 'Event 3', date: Date.today + 1, start_time: '20:00', location: 'Location 3', user: user)

      # event2 gets 3 upvotes
      3.times { |i| Upvote.create!(email: "user#{i}@example.com", username: "user#{i}", event: event2) }
      # event1 gets 1 upvote
      Upvote.create!(email: 'single@example.com', username: 'single', event: event1)
      # event3 gets 0 upvotes

      sorted = Event.sorted_by_upvotes.to_a
      expect(sorted.map(&:id)).to eq([event2.id, event1.id, event3.id])
    end

    it 'handles events with no upvotes' do
      event1 = Event.create!(title: 'Event 1', date: Date.today + 1, start_time: '18:00', location: 'Location 1', user: user)
      event2 = Event.create!(title: 'Event 2', date: Date.today + 1, start_time: '19:00', location: 'Location 2', user: user)

      sorted = Event.sorted_by_upvotes
      expect(sorted).to include(event1, event2)
    end

    it 'handles ties in upvote count' do
      event1 = Event.create!(title: 'Event 1', date: Date.today + 1, start_time: '18:00', location: 'Location 1', user: user)
      event2 = Event.create!(title: 'Event 2', date: Date.today + 1, start_time: '19:00', location: 'Location 2', user: user)

      Upvote.create!(email: 'user1@example.com', username: 'user1', event: event1)
      Upvote.create!(email: 'user2@example.com', username: 'user2', event: event2)

      sorted = Event.sorted_by_upvotes
      expect(sorted).to include(event1, event2)
    end
  end

  describe '.visible_to' do
    let(:other_user) { User.create!(email: 'other@example.com', provider: 'google_oauth2', uid: '67890') }
    let!(:public_event) { Event.create!(title: 'Public', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user) }
    let!(:private_event) { Event.create!(title: 'Private', date: Date.today + 1, start_time: '18:00', location: 'Hall', unlisted: true, allowed_emails: [user.email], user: user) }

    it 'shows all public events to anyone' do
      events = Event.visible_to(nil)
      expect(events).to include(public_event)
      expect(events).not_to include(private_event)
    end

    it 'shows private events to allowed users' do
      events = Event.visible_to(user)
      expect(events).to include(public_event, private_event)
    end

    it 'hides private events from non-allowed users' do
      events = Event.visible_to(other_user)
      expect(events).to include(public_event)
      expect(events).not_to include(private_event)
    end

    it 'shows private events to creator' do
      events = Event.visible_to(user)
      expect(events).to include(private_event)
    end
  end

  describe '#visible_to?' do
    let(:other_user) { User.create!(email: 'other@example.com', provider: 'google_oauth2', uid: '67890') }

    it 'public events are visible to anyone' do
      event = Event.create!(title: 'Public', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user)
      expect(event.visible_to?(nil)).to be true
      expect(event.visible_to?(other_user)).to be true
    end

    it 'private events are visible to allowed users' do
      event = Event.create!(
        title: 'Private',
        date: Date.today + 1,
        start_time: '18:00',
        location: 'Hall',
        unlisted: true,
        allowed_emails: [user.email],
        user: user
      )
      expect(event.visible_to?(user)).to be true
    end

    it 'private events are not visible to non-allowed users' do
      event = Event.create!(
        title: 'Private',
        date: Date.today + 1,
        start_time: '18:00',
        location: 'Hall',
        unlisted: true,
        allowed_emails: [user.email],
        user: user
      )
      expect(event.visible_to?(other_user)).to be false
      expect(event.visible_to?(nil)).to be false
    end

    it 'private events are visible to creator' do
      event = Event.create!(
        title: 'Private',
        date: Date.today + 1,
        start_time: '18:00',
        location: 'Hall',
        unlisted: true,
        allowed_emails: [],
        user: user
      )
      expect(event.visible_to?(user)).to be true
    end
  end
end