class Follow < ApplicationRecord
  # フォローする側のアソシエーション
  belongs_to :follower, class_name: "User", foreign_key: :follows_user_id
  # フォローされる側のアソシエーション
  belongs_to :followed, class_name: "User", foreign_key: :followed_user_id

  has_one :notification, as: :notifable, dependent: :destroy

  validates :follows_user_id, presence: true
  validates :followed_user_id, presence: true
  validates :follows_user_id, uniqueness: { scope: :followed_user_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:base, "自分自身をフォローすることはできません") if follows_user_id == followed_user_id
  end
end
