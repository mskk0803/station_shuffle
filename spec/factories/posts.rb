FactoryBot.define do
  factory :post do
    content {"Rspecテストです" }
    association :user
  end
end
