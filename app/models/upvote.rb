class Upvote < ApplicationRecord
  belongs_to :event

  # Validations
  validates :email, presence: true, 
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :username, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, uniqueness: { scope: :event_id, message: "has already upvoted this event" }

  validate :rate_limit_not_exceeded, on: :create

  before_validation :normalize_email

  def self.rate_limit_exceeded?(email, time_window = 1.hour, max_upvotes = 10)
    return false if email.blank?

    where(email: email.downcase)
        .where('created_at > ?', time_window.ago)
        .count >= max_upvotes
    end


  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def rate_limit_not_exceeded
    return if email.blank?

    if self.class.rate_limit_exceeded?(email)
      errors.add(:base, 'Rate limit exceeded. You can only upvote 10 events per hour.')
    end
  end
end
