class Upvote < ApplicationRecord
  belongs_to :event

  # Validations
  validates :email, presence: true, 
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :username, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, uniqueness: { scope: :event_id, message: "has already upvoted this event" }

  # Normalize email to lowercase before saving
  before_validation :normalize_email

  # Rate limiting: check if email has upvoted too many times recently
  def self.rate_limit_exceeded?(email, time_window = 1.hour, max_upvotes = 10)
    where(email: email.downcase)
      .where('created_at > ?', time_window.ago)
      .count >= max_upvotes
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end