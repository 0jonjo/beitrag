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

  describe 'top_rated' do
    let(:post1) { create(:post) }
    let(:post2) { create(:post) }
    let(:post3) { create(:post) }
    let(:post4) { create(:post) }


    before do
      create(:rating, post: post1, value: 5)
      create(:rating, post: post2, value: 3)
      create(:rating, post: post2, value: 4)
      create(:rating, post: post3, value: 2)
      post4
    end

    it 'returns posts ordered by average rating' do
      expect(Post.top_rated).to eq([ post1, post2, post3, post4 ])
    end

    it 'returns posts with no ratings' do
      expect(Post.top_rated.last).to eq(post4)
    end

    it 'returns posts respecting the limit' do
      expect(Post.top_rated(2)).to eq([ post1, post2 ])
    end
  end
end
