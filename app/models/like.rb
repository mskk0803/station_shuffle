class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :notification, as: :notifiable, dependent: :destroy

  # ユニーク制約
  validates :user_id, uniqueness: { scope: :post_id }
end
