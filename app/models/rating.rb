class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: :post_id, message: "can rate a post only once" }
end
