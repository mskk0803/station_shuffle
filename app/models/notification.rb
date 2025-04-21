class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :user_id, presence: true
  validates :notifiable_id, presence: true
  validates :notifiable_type, presence: true

  scope :unread, -> { where(read: false) }

  # 通知の種類
  def notifiable_types
    %w[Follow Like]
  end

  # 通知のバリデーション
  def valid_notifable_type?(type)
    notifiable_types.include?(type.to_s.classify)
  end

  # 通知の内容がフォローかどうか
  def follow?
    notifiable_type == 'Follow'
  end

  # 通知の内容がいいねかどうか
  def like?
    notifiable_type == 'Like'
  end
end
