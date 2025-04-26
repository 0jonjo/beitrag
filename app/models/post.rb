class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  def self.top_rated(limit = 10)
    Post.select("posts.*, COALESCE(AVG(ratings.value), 0) as average_rating")
        .left_joins(:ratings)
        .group("posts.id")
        .order("average_rating DESC, posts.id")
        .limit(limit)
  end
end
