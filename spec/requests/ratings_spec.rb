require 'rails_helper'

RSpec.describe 'Ratings Routes', type: :request do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:post_obj) { create(:post, user: user) }
    let(:valid_attributes) { { rating: { post_id: post_obj.id, user_id: user.id, value: 4 } } }
    let(:invalid_value_attributes) { { rating: { post_id: post_obj.id, user_id: user.id, value: 10 } } }
    let(:missing_value_attributes) { { rating: { post_id: post_obj.id, user_id: user.id } } }
    let(:nonexistent_post_attributes) { { rating: { post_id: 9999, user_id: user.id, value: 4 } } }
    let(:nonexistent_user_attributes) { { rating: { post_id: post_obj.id, user_id: 9999, value: 4 } } }
    let(:json_response) { JSON.parse(response.body) }

    context 'with valid attributes' do
      it 'creates a new rating' do
        expect {
          post api_v1_ratings_path, params: valid_attributes, as: :json
        }.to change(Rating, :count).by(1)
      end

      it 'returns a success response' do
        post api_v1_ratings_path, params: valid_attributes, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'returns the created rating with the average rating' do
        post api_v1_ratings_path, params: valid_attributes, as: :json

        expect(json_response['rating']).to be_present
        expect(json_response['average_rating']).to eq(4.0)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a rating with invalid value' do
        expect {
          post api_v1_ratings_path, params: invalid_value_attributes, as: :json
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Value must be less than or equal to 5")
      end

      it 'does not create a rating without value' do
        expect {
          post api_v1_ratings_path, params: missing_value_attributes, as: :json
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Value can't be blank")
      end

      it 'does not create a rating for non-existent post' do
        expect {
          post api_v1_ratings_path, params: nonexistent_post_attributes, as: :json
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Post with ID 9999 not found")
      end

      it 'does not create a rating for non-existent user' do
        expect {
          post api_v1_ratings_path, params: nonexistent_user_attributes, as: :json
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("User with ID 9999 not found")
      end
    end

    context 'when user tries to rate the same post twice' do
      before { create(:rating, user: user, post: post_obj, value: 3) }

      it 'does not create a duplicate rating' do
        expect {
          post api_v1_ratings_path, params: valid_attributes, as: :json
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("User has already rated this post")
      end
    end

    context 'when multiple users rate the same post' do
      let(:second_user) { create(:user) }
      let(:second_user_attributes) { { rating: { post_id: post_obj.id, user_id: second_user.id, value: 3 } } }

      before { post api_v1_ratings_path, params: valid_attributes, as: :json }

      it 'calculates the average rating correctly' do
        post api_v1_ratings_path, params: second_user_attributes, as: :json

        expect(json_response['average_rating']).to eq(3.5)
      end
    end
  end
end
