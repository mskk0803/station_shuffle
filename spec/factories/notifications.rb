FactoryBot.define do
  # いいね通知
  factory :like_notification, class: "notification"  do
    association :user
    association :notifable, factory: :like
  end

  # フォロー通知
  factory :follow_notification, class: "notification" do
    association :user
    association :notifable, factory: :follow
  end

  # フォローリクエスト通知
  factory :follow_request_notification, class: "notification" do
    association :user
    association :notifable, factory: :follow_request
  end
end
