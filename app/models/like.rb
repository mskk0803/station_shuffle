class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :notification, as: :notifable, dependent: :destroy

  # ユニーク制約
  validates :user_id, uniqueness: { scope: :post_id }

  validate :cannot_like_self

  private

  def cannot_like_self
    return if user_id.nil? || post.nil? || post.user.nil?
    if user_id == post.user.id
      errors.add(:base, "自分自身をいいねすることはできません")
    end
  end
end
