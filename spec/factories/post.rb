FactoryBot.define do
  factory :post do
    title { Faker::Book.title }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    ip { Faker::Internet.ip_v4_address }
    association :user
  end
end
