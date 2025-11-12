# Add this to your existing Event model

class Event < ApplicationRecord
  # Add this association
  has_many :upvotes, dependent: :destroy
  belongs_to :user, optional: true
  has_one_attached :image

  validates :title, presence: true
  validates :date, presence: true
  validates :start_time, presence: true

  # Add this method to get upvote count
  def upvote_count
    upvotes.count
  end

  # Add this scope for sorting by upvotes
  scope :sorted_by_upvotes, -> { 
    left_joins(:upvotes)
      .group(:id)
      .order('COUNT(upvotes.id) DESC, events.created_at DESC')
  }

  # Check if an email has already upvoted this event
  def upvoted_by?(email)
    upvotes.exists?(email: email.downcase)
  end
end