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

  # Get IPs that were used by multiple different authors
  def self.ips_with_multiple_authors
    joins(:user)
      .select("posts.ip, array_agg(DISTINCT users.login) as logins")
      .group("posts.ip")
      .having("COUNT(DISTINCT user_id) > 1")
  end
end
