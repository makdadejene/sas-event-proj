# app/models/event.rb

class Event < ApplicationRecord
  belongs_to :user, optional: true
  has_many :upvotes, dependent: :destroy
  has_one_attached :image

  # Validations
  validates :title, presence: true
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate  :end_time_after_start_time 

  # Scope for sorting by upvotes
  scope :sorted_by_upvotes, -> { 
    left_joins(:upvotes)
      .group(:id)
      .order('COUNT(upvotes.id) DESC, events.created_at DESC')
  }

  # Get upvote count
  def upvote_count
    upvotes.count
  end

  # Check if a user has upvoted this event
  def upvoted_by?(user)
    return false if user.nil?
    
    # For now, just check by email since user_id doesn't exist yet
    if user.is_a?(User)
      upvotes.exists?(email: user.email.downcase)
    elsif user.is_a?(String)
      upvotes.exists?(email: user.downcase)
    else
      false
    end
  end

  # Toggle upvote for a user
  def toggle_upvote(user)
    return false if user.nil?
    
    user_email = user.email.downcase
    existing_upvote = upvotes.find_by(email: user_email)
    
    if existing_upvote
      # Remove upvote
      existing_upvote.destroy
      false
    else
      # Add upvote
      upvotes.create(
        email: user_email,
        username: user.name || user.email
      )
      true
    end
  end
  
  # Override tags getter to ensure it's always an array
  def tags
    super || []
  end
  
  # Override tags setter to handle strings and arrays
  def tags=(value)
    if value.is_a?(String)
      super(value.split(',').map(&:strip).reject(&:blank?))
    elsif value.is_a?(Array)
      super(value.reject(&:blank?))
    else
      super([])
    end
  end


  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "can't be earlier than the start time")
    end
  end
end