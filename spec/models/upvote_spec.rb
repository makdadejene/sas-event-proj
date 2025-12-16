# spec/models/upvote_spec.rb
require 'rails_helper'

RSpec.describe Upvote, type: :model do
  let(:user) { User.create!(email: 'test@example.com', provider: 'google_oauth2', uid: '12345') }
  let(:event) { Event.create!(title: 'Test Event', date: Date.today + 1, start_time: '18:00', location: 'Test Location', user: user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      upvote = Upvote.new(email: 'voter@example.com', username: 'voter', event: event)
      expect(upvote).to be_valid
    end

    it 'is invalid without email' do
      upvote = Upvote.new(username: 'voter', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without username' do
      upvote = Upvote.new(email: 'voter@example.com', event: event)
      expect(upvote).not_to be_valid
      expect(upvote.errors[:username]).to include("can't be blank")
    end

    it 'is invalid without event' do
      upvote = Upvote.new(email: 'voter@example.com', username: 'voter')
      expect(upvote).not_to be_valid
    end

    it 'prevents duplicate upvotes from same email on same event' do
      Upvote.create!(email: 'voter@example.com', username: 'voter', event: event)
      duplicate = Upvote.new(email: 'voter@example.com', username: 'voter', event: event)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already upvoted this event")
    end

    it 'allows same email to upvote different events' do
      event2 = Event.create!(title: 'Event 2', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user)
      Upvote.create!(email: 'voter@example.com', username: 'voter', event: event)
      upvote2 = Upvote.new(email: 'voter@example.com', username: 'voter', event: event2)
      expect(upvote2).to be_valid
    end

    it 'is case insensitive for duplicate emails' do
      Upvote.create!(email: 'voter@example.com', username: 'voter', event: event)
      duplicate = Upvote.new(email: 'VOTER@EXAMPLE.COM', username: 'voter', event: event)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to event' do
      upvote = Upvote.new
      expect(upvote).to respond_to(:event)
    end

    it 'is destroyed when event is destroyed' do
      upvote = event.upvotes.create!(email: 'voter@example.com', username: 'voter')
      expect {
        event.destroy
      }.to change { Upvote.count }.by(-1)
    end
  end

  describe 'callbacks' do
    it 'normalizes email to lowercase before save' do
      upvote = Upvote.create!(email: 'VOTER@EXAMPLE.COM', username: 'voter', event: event)
      expect(upvote.reload.email).to eq('voter@example.com')
    end

    it 'strips whitespace from email' do
      upvote = Upvote.create!(email: '  voter@example.com  ', username: 'voter', event: event)
      expect(upvote.reload.email).to eq('voter@example.com')
    end
  end
end