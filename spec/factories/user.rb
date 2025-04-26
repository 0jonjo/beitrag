FactoryBot.define do
  factory :user do
    login { Faker::Internet.username(specifier: 5..10) }
  end
end
