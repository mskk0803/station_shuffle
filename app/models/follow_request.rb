class FollowRequest < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :requestee, class_name: 'User'

  # 保留中：０，承認済み：１
  enum status: { pending: 0, accepted: 1 }

  validates :requester_id, presence: true
  validates :requestee_id, presence: true
end
