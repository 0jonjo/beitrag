require 'rails_helper'

RSpec.describe PostCreatorService do
  let(:user) { create(:user) }
  let(:valid_attributes) { { title: 'Test Title', body: 'Test Body',
                          ip: '192.0.2.255', login: user.login } }
  let(:invalid_attributes) { { title: '', body: 'Test Body',
                          ip: '192.0.2.255', login: 'without_login' } }
  let(:guest_attributes) { { title: 'Test Title', body: 'Test Body',
                          ip: '192.0.2.255', login: 'without_login' } }

  describe '#call' do
    context 'when post is valid' do
      it 'creates a new post when user is valid' do
        service = described_class.new(valid_attributes).call

        expect(service.success?).to be true
        expect(service.created_post).to be_a(Post)
        expect(service.user).to be_a(User)
        expect(service.created_post.user).to eq(service.user)
      end

      it 'creates a new post with a guest user when user does not exist' do
        service = described_class.new(guest_attributes).call

        expect(service.success?).to be true
        expect(service.user.login).to eq(User.last.login)
        expect(service.created_post.user).to eq(service.user)
      end
    end

    context 'when post is invalid' do
      it 'returns failure with errors when post is invalid' do
        service = described_class.new(invalid_attributes).call

        expect(service.success?).to be false
        expect(service.errors).to include("Title can't be blank")
      end

      it 'do not create a user when post is invalid' do
        service = described_class.new(invalid_attributes).call

        expect(service.success?).to be false
        expect(service.user).to be_nil
        expect(User.count).to eq(0)
      end
    end
  end
end
