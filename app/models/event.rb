class Event < ApplicationRecord
  validates :title, presence: true
  validates :date,  presence: true
  has_one_attached :image
end
