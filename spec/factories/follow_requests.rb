FactoryBot.define do
  factory :follow_request do
    association :requester, factory: :user
    association :requestee, factory: :user
  end
end
