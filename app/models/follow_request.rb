class FollowRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :requestee, class_name: "User"

  has_one :notification, as: :notifable

  # 保留中：０
  enum status: { pending: 0 }

  validates :requester_id, presence: true
  validates :requestee_id, presence: true
end
