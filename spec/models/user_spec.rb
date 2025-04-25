require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:login) }
  end
end
