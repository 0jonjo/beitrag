require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
  end
end
