FactoryBot.define do
  factory :rating do
    value { rand(1..5) }
    association :user
    association :post
  end
end
