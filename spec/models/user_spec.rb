require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(email: nil, password: 'password123')
      expect(user).not_to be_valid
    end

    it 'is invalid without a password for non-OAuth users' do
      user = User.new(email: 'test@example.com', password: nil, provider: nil)
      expect(user).not_to be_valid
    end

    it 'is valid without password for OAuth users' do
      user = User.new(email: 'test@example.com', provider: 'google_oauth2', uid: '123')
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it 'has many events' do
      user = User.new(email: 'test@example.com', password: 'password123')
      expect(user).to respond_to(:events)
    end

    it 'destroys associated events when destroyed' do
      user = User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      event = user.events.create!(title: 'Test Event', date: Date.today, start_time: '18:00')
      
      expect { user.destroy }.to change { Event.count }.by(-1)
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'oauth@example.com',
          name: 'OAuth User'
        }
      })
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          User.from_omniauth(auth)
        }.to change(User, :count).by(1)
      end

      it 'sets provider and uid' do
        user = User.from_omniauth(auth)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user.email).to eq('oauth@example.com')
        expect(user.name).to eq('OAuth User')
      end

      it 'generates a password' do
        user = User.from_omniauth(auth)
        expect(user.encrypted_password).to be_present
      end
    end

    context 'when user exists with provider and uid' do
      let!(:existing_user) do
        User.create!(
          provider: 'google_oauth2',
          uid: '123456789',
          email: 'oauth@example.com',
          name: 'Existing User'
        )
      end

      it 'returns existing user' do
        user = User.from_omniauth(auth)
        expect(user.id).to eq(existing_user.id)
      end

      it 'does not create a new user' do
        expect {
          User.from_omniauth(auth)
        }.not_to change(User, :count)
      end
    end

    context 'when user exists with email but no OAuth info' do
      let!(:existing_user) do
        User.create!(
          email: 'oauth@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
      end

      it 'updates existing user with OAuth info' do
        user = User.from_omniauth(auth)
        expect(user.id).to eq(existing_user.id)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
      end

      it 'does not create a new user' do
        expect {
          User.from_omniauth(auth)
        }.not_to change(User, :count)
      end
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes omniauthable' do
      expect(User.devise_modules).to include(:omniauthable)
    end
  end

  describe '#password_required?' do
    context 'for OAuth users' do
      let(:oauth_user) { User.new(email: 'test@example.com', provider: 'google_oauth2', uid: '123') }

      it 'does not require password' do
        expect(oauth_user.send(:password_required?)).to be false
      end
    end

    context 'for non-OAuth users' do
      let(:regular_user) { User.new(email: 'test@example.com') }

      it 'requires password for new records' do
        expect(regular_user.send(:password_required?)).to be true
      end

      it 'requires password when password is being changed' do
        user = User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
        user.password = 'newpassword'
        expect(user.send(:password_required?)).to be true
      end
    end
  end
end