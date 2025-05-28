FactoryBot.define do
  factory :post do
    content { "Rspecテストです" }
    station { "東京駅" }
    association :user
  end
end
