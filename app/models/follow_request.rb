class FollowRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :requestee, class_name: "User"

  has_one :notification, as: :notifable, dependent: :destroy

  # 保留中：０
  enum status: { pending: 0 }

  validates :requester_id, presence: true
  validates :requestee_id, presence: true

  validates :requester_id, uniqueness: { scope: :requestee_id }
  validate :cannot_request_self

  private
  def cannot_request_self
    errors.add(:base, "自分自身にフォローリクエストを送ることはできません") if requester_id == requestee_id
  end
end
