class PostCreatorService
  attr_reader :post, :errors, :created_post, :user

  def initialize(post)
    @post = post
    @errors = []
    @success = false
  end

  def call
    ActiveRecord::Base.transaction do
      @user = find_or_create_user
      @created_post = create_post
      @success = true
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      @success = false
    end
    self
  end

  def success?
    @success
  end

  private

  def find_or_create_user
    user_exists? ? User.find(post.user_id) : User.create!(login: "guest_#{SecureRandom.hex(4)}")
  end

  def create_post
    Post.create!(
      title: post.title,
      body: post.body,
      ip: post.ip,
      user: user
    )
  end

  def user_exists?
    User.exists?(id: post.user_id)
  end
end
