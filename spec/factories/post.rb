FactoryBot.define do
  factory :post do
    title { "Sample Post Title" }
    body { "This is a sample post body." }
    ip { "192.0.2.126" }
    association :user
  end
end
