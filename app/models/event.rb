class Event < ApplicationRecord
  validates :title, presence: true
  validates :date,  presence: true
  validates :time,  presence: true
  has_one_attached :image
end
