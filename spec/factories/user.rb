FactoryBot.define do
  factory :user do
    login { Faker::Internet.unique.username(specifier: 5..10) }
  end
end
