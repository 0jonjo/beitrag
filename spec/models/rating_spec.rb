require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }

    describe 'uniqueness validation' do
      let(:user) { create(:user) }
      let(:post) { create(:post, user: user) }

      it 'validates uniqueness of user_id scoped to post_id' do
        create(:rating, user: user, post: post, value: 4)
        duplicate_rating = build(:rating, user: user, post: post, value: 5)

        expect(duplicate_rating).not_to be_valid
        expect(duplicate_rating.errors.messages[:user_id]).to include('A post can be rated once')
      end

      it 'allows the same user to rate different posts' do
        another_post = create(:post, user: user)
        create(:rating, user: user, post: post, value: 4)
        second_rating = build(:rating, user: user, post: another_post, value: 5)

        expect(second_rating).to be_valid
      end

      it 'allows different users to rate the same post' do
        another_user = create(:user)
        create(:rating, user: user, post: post, value: 4)
        second_rating = build(:rating, user: another_user, post: post, value: 5)

        expect(second_rating).to be_valid
      end
    end
  end
end
