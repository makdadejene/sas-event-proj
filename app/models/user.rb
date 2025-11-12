# app/models/user.rb
class User < ApplicationRecord
  has_many :events, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Make password optional for OAuth users
  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  def self.from_omniauth(auth)
    # First, try to find the user by provider + uid
    user = where(provider: auth.provider, uid: auth.uid).first

    # If not found, try finding by email (for users who signed up manually)
    user ||= where(email: auth.info.email).first

    if user
      # If the user exists but doesn't have OAuth info yet, update it
      if user.provider.blank? || user.uid.blank?
        user.update(provider: auth.provider, uid: auth.uid)
      end
      user
    else
      # Otherwise, create a new user from Google data
      create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        name: auth.info.name,
        password: Devise.friendly_token[0, 20]
      )
    end
  end

  protected

  def password_required?
    # Password is only required if:
    # 1. It's NOT an OAuth user (no provider set)
    # 2. AND it's a new record OR password is being changed
    provider.blank? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end