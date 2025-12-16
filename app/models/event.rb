# app/models/event.rb

class Event < ApplicationRecord
  belongs_to :user, optional: true
  has_many :upvotes, dependent: :destroy 
  has_one_attached :image

  # Validations
  validates :title, presence: true, 
                    length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :date, presence: true
  validates :start_time, presence: true
  validates :location, presence: true, length: { minimum: 3 }
  
  # Custom validations
  validate :date_must_be_in_future
  validate :end_time_after_start_time
  validate :image_validation 

  # Callbacks
  before_save :ensure_creator_in_allowed_emails


  # Scope for sorting by upvotes
  scope :sorted_by_upvotes, -> { 
    left_joins(:upvotes)
      .group(:id)
      .order('COUNT(upvotes.id) DESC, events.created_at DESC')
  }

  # Scopes for visibility
  scope :listed, -> { where(unlisted: [false, nil]) }
  scope :unlisted_events, -> { where(unlisted: true) }
  scope :visible_to, ->(user) {
  if user
    # Logged in users see: public events + their own unlisted events
    where(unlisted: [nil, false]).or(where(user: user))
  else
    # Logged out users only see public events
    where(unlisted: [nil, false])
  end
}

  # Get upvote count
  def upvote_count
    upvotes.count
  end

  # Check if a user has upvoted this event
  def upvoted_by?(user)
    return false if user.nil?
    
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
      existing_upvote.destroy
      false
    else
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

  # Override allowed_emails getter to ensure it's always an array
  def allowed_emails
    super || []
  end

  # Override allowed_emails setter to handle comma-separated strings
  def allowed_emails=(value)
    if value.is_a?(String)
      super(value.split(',').map { |e| e.strip.downcase }.reject(&:blank?))
    elsif value.is_a?(Array)
      super(value.map { |e| e.to_s.strip.downcase }.reject(&:blank?))
    else
      super([])
    end
  end

  # Check if a user can view this event
  def visible_to?(user)
    return true unless unlisted?
    return false if user.nil?
    allowed_emails.include?(user.email.downcase)
  end

  private

  # Validate that date is not in the past (allow today and future dates)
  def date_must_be_in_future
    if date.present? && date < Date.today
      errors.add(:date, "must be in the future")
    end
  end

  # Validate that end_time is after start_time (only if both are present)
  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  # Validate image attachment
  def image_validation
    return unless image.attached?

    # Check file type
    unless image.content_type.in?(%w[image/jpeg image/jpg image/png])
      errors.add(:image, "must be a valid image file")
    end

    # Check file size (5MB = 5 * 1024 * 1024 bytes)
    if image.byte_size > 5.megabytes
      errors.add(:image, "file size must be less than 5MB")
    end
  end

  # Ensure the creator's email is always in the allowed_emails list for unlisted events
  def ensure_creator_in_allowed_emails
    return unless unlisted? && user.present?
    creator_email = user.email.downcase
    unless allowed_emails.include?(creator_email)
      self.allowed_emails = allowed_emails + [creator_email]
    end
  end
end