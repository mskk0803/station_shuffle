FactoryBot.define do
  factory :checkin do
    station { "東京駅" }
    association :user
  end
end
