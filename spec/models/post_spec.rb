require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:ip) }
  end

  describe '#user_exists?' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it 'returns true if the user exists' do
      post = create(:post, user: user)
      expect(post.user_exists?).to be true
    end

    it 'returns false if the user does not exist' do
      post = build(:post, user_id: user.id + 9999)
      expect(post.user_exists?).to be false
    end
  end

  describe 'create_post' do
    let(:user) { create(:user) }
    let(:post) { build(:post, user: user) }
    let(:post_without_user) { build(:post, user_id: user.id + 9999) }
    let(:post_invalid) { build(:post, title: nil) }

    context 'when post is valid' do
      it 'creates a new post when user is valid' do
        result = post.create_post

        expect(result[:post]).to be_a(Post)
        expect(result[:user]).to be_a(User)
        expect(result[:post].user).to eq(result[:user])
      end

      it 'creates a new post with a guest user when user does not exist' do
        result = post_without_user.create_post

        expect(result[:user].login).to start_with('guest_')
        expect(result[:post].user).to eq(result[:user])
      end
    end

    context 'when post is invalid' do
      it 'returns errors when post is invalid' do
        result = post_invalid.create_post

        expect(result[:errors]).not_to be_nil
        expect(result[:errors]).to include("Title can't be blank")
      end
    end
  end
end
