class Post < ApplicationRecord
  mount_uploader :image, ImageUploader

  belongs_to :user
  has_many :likes, dependent: :destroy

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 255 }

  # 検索用スコープ
  scope :search_by_content, ->(content) {
    where("content LIKE ?", "%#{sanitize_sql_like(content)}%")  if content.present?
  }
end
