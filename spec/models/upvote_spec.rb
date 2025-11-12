require 'rails_helper'

RSpec.describe Upvote, type: :model do
  let(:user) { User.create!(email: 'user@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:event) { Event.create!(title: 'Test Event', description: 'Test', date: Date.today, start_time: '12:00', location: 'Test Location', user: user) }

  describe 'associations' do
    it 'belongs to event' do
      upvote = Upvote.new(email: 'test@example.com', username: 'testuser', event: event)
      expect(upvote.event).to eq(event)
    end
  end

  describe 'validations' do
    it 'requires an email' do
      upvote = Upvote.new(username: 'testuser', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:email]).to include("can't be blank")
    end

    it 'requires a username' do
      upvote = Upvote.new(email: 'test@example.com', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:username]).to include("can't be blank")
    end

    it 'validates email format' do
      upvote = Upvote.new(email: 'invalid-email', username: 'testuser', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:email]).to include('must be a valid email address')
    end

    it 'accepts valid email format' do
      upvote = Upvote.new(email: 'test@example.com', username: 'testuser', event: event)
      expect(upvote).to be_valid
    end

    it 'validates username length' do
      upvote = Upvote.new(email: 'test@example.com', username: 'a', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:username]).to include('is too short (minimum is 2 characters)')
    end

    it 'prevents duplicate upvotes from same email per event' do
      Upvote.create!(email: 'test@example.com', username: 'testuser', event: event)
      duplicate = Upvote.new(email: 'test@example.com', username: 'testuser2', event: event)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already upvoted this event')
    end

    it 'allows same email to upvote different events' do
      event2 = Event.create!(title: 'Another Event', description: 'Test', date: Date.today, start_time: '14:00', location: 'Test', user: user)
      Upvote.create!(email: 'test@example.com', username: 'testuser', event: event)
      upvote2 = Upvote.new(email: 'test@example.com', username: 'testuser', event: event2)
      expect(upvote2).to be_valid
    end
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase' do
      upvote = Upvote.create!(email: 'TEST@EXAMPLE.COM', username: 'testuser', event: event)
      expect(upvote.email).to eq('test@example.com')
    end

    it 'strips whitespace from email' do
      upvote = Upvote.create!(email: '  test@example.com  ', username: 'testuser', event: event)
      expect(upvote.email).to eq('test@example.com')
    end
  end

  describe '.rate_limit_exceeded?' do
    let(:email) { 'test@example.com' }

    it 'returns false when under rate limit' do
      5.times do |i|
        event_temp = Event.create!(title: "Event #{i}", description: 'Test', date: Date.today, start_time: '12:00', location: 'Test', user: user)
        Upvote.create!(email: email, username: 'testuser', event: event_temp)
      end
      expect(Upvote.rate_limit_exceeded?(email)).to be false
    end

    it 'returns true when rate limit exceeded' do
      10.times do |i|
        event_temp = Event.create!(title: "Event #{i}", description: 'Test', date: Date.today, start_time: '12:00', location: 'Test', user: user)
        Upvote.create!(email: email, username: 'testuser', event: event_temp)
      end
      expect(Upvote.rate_limit_exceeded?(email)).to be true
    end

    it 'only counts upvotes within time window' do
      10.times do |i|
        event_temp = Event.create!(title: "Old Event #{i}", description: 'Test', date: Date.today, start_time: '12:00', location: 'Test', user: user)
        upvote = Upvote.create!(email: email, username: 'testuser', event: event_temp)
        upvote.update_column(:created_at, 2.hours.ago)
      end
      
      expect(Upvote.rate_limit_exceeded?(email)).to be false
    end
  end
end