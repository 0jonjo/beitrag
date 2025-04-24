class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :value, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
end
