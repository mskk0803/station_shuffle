class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifable, polymorphic: true

  validates :user_id, presence: true
  validates :notifable_id, presence: true
  validates :notifable_type, presence: true

  scope :unread, -> { where(read: false) }

  # 通知の種類
  def notifiable_types
    %w[Follow Like]
  end

  # 通知のバリデーション
  def valid_notifable_type?(type)
    notifable_types.include?(type.to_s.classify)
  end

  # 通知の内容がフォローかどうか
  def follow?
    notifable_type == 'Follow'
  end

  # 通知の内容がいいねかどうか
  def like?
    notifable_type == 'Like'
  end
end
