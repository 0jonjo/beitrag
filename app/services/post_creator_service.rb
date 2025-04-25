class PostCreatorService
  attr_reader :params, :errors, :created_post, :user

  def initialize(params)
    @params = params
    @errors = []
    @success = false
  end

  def call
    ActiveRecord::Base.transaction do
      @user = find_or_create_user
      @created_post = create_post
      @success = true
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.record.errors.full_messages
    @success = false
    @user = nil
  ensure
    return self
  end

  def success?
    @success
  end

  private

  def find_or_create_user
    User.find_by!(login: @params[:login])
  rescue ActiveRecord::RecordNotFound
    User.create!(login: @params[:login])
  end

  def create_post
    Post.create!(
      title: @params[:title],
      body: @params[:body],
      ip: @params[:ip],
      user: @user
    )
  end
end
