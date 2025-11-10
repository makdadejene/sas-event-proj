class Event < ApplicationRecord
  validates :title, presence: true
  validates :date, presence: true
  has_one_attached :image
  
  before_validation :ensure_tags_is_array
  
  private
  
  def ensure_tags_is_array
    self.tags = [] if tags.nil?
  end
end
