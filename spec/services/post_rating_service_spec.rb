require 'rails_helper'

RSpec.describe PostRatingService do
  let(:user) { create(:user) }
  let(:second_user) { create(:user) }
  let(:post_obj) { create(:post, user: user) }
  let(:valid_params) { { post_id: post_obj.id, user_id: user.id, value: 4 } }
  let(:edit_params) { { post_id: post_obj.id, user_id: user.id, value: 5 } }
  let(:second_rating_params) { { post_id: post_obj.id, user_id: second_user.id, value: 3 } }
  let(:invalid_params) { { post_id: post_obj.id, user_id: user.id, value: 6 } }
  let(:nonexistent_post_params) { { post_id: 9999, user_id: user.id, value: 4 } }
  let(:nonexistent_user_params) { { post_id: post_obj.id, user_id: 9999, value: 4 } }

  describe '#call' do
    context 'when params are valid' do
      it 'creates a new rating' do
        expect {
          service = described_class.new(valid_params).call
          expect(service.success?).to be true
        }.to change(Rating, :count).by(1)
      end

      it 'returns the rating and average rating' do
        service = described_class.new(valid_params).call

        expect(service.rating).to be_a(Rating)
        expect(service.average_rating).to eq(4.0)
      end

      it 'do not update an existing rating' do
        described_class.new(valid_params).call

        service = described_class.new(edit_params).call
        expect(service.success?).to be false
      end

      it 'calculates the average correctly with multiple ratings' do
        described_class.new(valid_params).call

        service = described_class.new(second_rating_params).call

        expect(service.average_rating).to eq(3.5)
      end
    end

    context 'when params are invalid' do
      it 'returns errors for invalid rating value' do
        service = described_class.new(invalid_params).call

        expect(service.success?).to be false
        expect(service.errors).to include("Value must be less than or equal to 5")
      end

      it 'returns errors for non-existent post' do
        service = described_class.new(nonexistent_post_params).call

        expect(service.success?).to be false
        # Updated to match the custom error message format
        expect(service.errors.first).to eq("Post with ID 9999 not found")
      end

      it 'returns errors for non-existent user' do
        service = described_class.new(nonexistent_user_params).call

        expect(service.success?).to be false
        # Updated to match the custom error message format
        expect(service.errors.first).to eq("User with ID 9999 not found")
      end

      it 'do not create a rating for non-existent user' do
        expect {
          described_class.new(nonexistent_user_params).call
        }.not_to change(Rating, :count)
      end

      it 'do not create a rating for non-existent post' do
        expect {
          described_class.new(nonexistent_post_params).call
        }.not_to change(Rating, :count)
      end
    end
  end
end
