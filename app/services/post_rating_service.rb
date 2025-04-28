class PostRatingService
  attr_reader :errors, :rating, :average_rating

  def initialize(params)
    @post_id = params[:post_id]
    @user_id = params[:user_id]
    @value = params[:value]
    @errors = []
    @success = false
  end

  def call
    ActiveRecord::Base.transaction do
      check_post
      check_user
      check_rating
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

  def check_post
    raise ActiveRecord::RecordNotFound.new("Post with ID #{@post_id} not found") unless Post.exists?(@post_id)
  end

  def check_user
    raise ActiveRecord::RecordNotFound.new("User with ID #{@user_id} not found") unless User.exists?(@user_id)
  end

  def check_rating
    existing_rating = Rating.exists?(post_id: @post_id, user_id: @user_id)
    if existing_rating
      rating = Rating.new
      rating.errors.add(:base, "User has already rated this post")
      raise ActiveRecord::RecordInvalid.new(rating)
    end
  end
  def create_rating
    Rating.create!(post_id: @post_id, user_id: @user_id, value: @value)
  end

  def calculate_average_rating
    Rating.where(post_id: @post_id).average(:value).to_f.round(2)
  end
end
