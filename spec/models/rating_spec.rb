require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
    it { should validate_numericality_of(:value).only_integer }

    describe 'uniqueness validation' do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:post) { create(:post, user: user) }
      let(:another_post) { create(:post, user: another_user) }
      let(:rating) { create(:rating, user: user, post: post, value: 4) }
      let(:another_rating_same_user) { build(:rating, user: user, post: another_post, value: 5) }
      let(:duplicate_rating) { build(:rating, user: user, post: post, value: 5) }
      let(:another_rating) { build(:rating, user: another_user, post: post, value: 5) }

      it 'validates uniqueness of user_id scoped to post_id' do
        rating
        duplicate_rating
        expect(duplicate_rating).not_to be_valid
        expect(duplicate_rating.errors.messages[:user_id]).to include('can rate a post only once')
      end

      it 'allows the same user to rate different posts' do
        another_post
        rating
        expect(another_rating_same_user).to be_valid
      end

      it 'allows different users to rate the same post' do
        rating
        expect(another_rating).to be_valid
      end
    end
  end
end
