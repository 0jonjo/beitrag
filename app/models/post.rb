class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  def user_exists?
    User.exists?(id: user_id)
  end

  def create_post
    ActiveRecord::Base.transaction do
      user = user_exists? ? User.find(user_id) : User.create!(login: "guest_#{user_id}")
      post = Post.create!(title: title, body: body, ip: ip, user: user)

      { post: post, user: user }
    rescue ActiveRecord::RecordInvalid => e
      { errors: e.record.errors.full_messages }
    end
  end
end
