require 'rails_helper'

RSpec.describe PostCreatorService do
  let(:user) { create(:user) }
  let(:post_with_user) { build(:post, user: user) }
  let(:post_without_user) { build(:post, user_id: user.id + 9999) }
  let(:post_invalid) { build(:post, title: nil) }

  describe '#call' do
    context 'when post is valid' do
      it 'creates a new post when user is valid' do
        service = described_class.new(post_with_user).call

        expect(service.success?).to be true
        expect(service.created_post).to be_a(Post)
        expect(service.user).to be_a(User)
        expect(service.created_post.user).to eq(service.user)
      end

      it 'creates a new post with a guest user when user does not exist' do
        service = described_class.new(post_without_user).call

        expect(service.success?).to be true
        expect(service.user.login).to start_with('guest_')
        expect(service.created_post.user).to eq(service.user)
      end
    end

    context 'when post is invalid' do
      it 'returns failure with errors when post is invalid' do
        service = described_class.new(post_invalid).call

        expect(service.success?).to be false
        expect(service.errors).not_to be_empty
        expect(service.errors).to include("Title can't be blank")
      end
    end
  end
end
