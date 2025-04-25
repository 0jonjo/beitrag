require 'rails_helper'

RSpec.describe 'Posts Routes', type: :request do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:valid_attributes) { { post: { title: 'Test Title', body: 'Test Body',
                              ip: '192.0.2.255', user_id: user.id } } }
    let(:invalid_attributes) { { post: { title: '', body: 'Test Body',
                              ip: '192.0.2.255', user_id: user.id } } }
    let(:guest_attributes) { { post: { title: 'Test Title', body: 'Test Body',
                              ip: '192.0.2.255', user_id: user.id + 9999 } } }

    context 'with valid attributes' do
      context 'when user exists' do
        it 'creates a new post' do
          expect {
            post api_v1_posts_path, params: valid_attributes
          }.to change(Post, :count).by(1)
        end

        it 'returns a success response' do
          post api_v1_posts_path, params: valid_attributes, as: :json

          expect(response).to have_http_status(:created)
        end

        it 'returns the created post with the user' do
          post api_v1_posts_path, params: valid_attributes, as: :json

          json_response = JSON.parse(response.body)
          expect(json_response['post']).to be_present
          expect(json_response['user']).to be_present
          expect(json_response['post']['user_id']).to eq(user.id)
        end
      end

      context 'when user does not exist' do
        it 'creates a new post with a guest user' do
          expect {
            post api_v1_posts_path, params: guest_attributes
          }.to change(Post, :count).by(1)
        end

        it 'returns a success response' do
          post api_v1_posts_path, params: guest_attributes, as: :json

          expect(response).to have_http_status(:created)
        end

        it 'returns the created post with a guest user' do
          post api_v1_posts_path, params: guest_attributes, as: :json

          json_response = JSON.parse(response.body)
          expect(json_response['post']).to be_present
          expect(json_response['user']).to be_present
          expect(json_response['user']['login']).to start_with('guest_')
        end
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new post' do
        expect {
          post api_v1_posts_path, params: invalid_attributes
        }.not_to change(Post, :count)
      end

      it 'returns an unprocessable entity response' do
        post api_v1_posts_path, params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post api_v1_posts_path, params: invalid_attributes, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end
  end
end
