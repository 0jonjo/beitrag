class PostRatingService
  attr_reader :post_id, :user_id, :value, :errors, :rating, :average_rating

  def initialize(params)
    @post_id = params[:post_id]
    @user_id = params[:user_id]
    @value = params[:value]
    @errors = []
    @success = false
  end

  def call
    ActiveRecord::Base.transaction do
      @post = find_post
      @user = find_user
      @rating = create_rating
      @average_rating = calculate_average_rating
      @success = true
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      @success = false
    rescue ActiveRecord::RecordNotFound => e
      @errors << e.message
      @success = false
    end
    self
  end

  def success?
    @success
  end

  private

  def find_post
    Post.find(post_id)
  end

  def find_user
    User.find(user_id)
  end

  def create_rating
    Rating.create!(post_id: post_id, user_id: user_id, value: value)
  end

  def calculate_average_rating
    @post.with_lock do
      @post.ratings.average(:value).to_f
    end
  end
end
