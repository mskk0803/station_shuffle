class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy

  validates :user_id, presence: true
  validates :content, presence: true

  # ransackのホワイトリスト
  def self.ransackable_attributes(auth_object = nil)
    %w(content)
  end

  def self.ransackable_associations(auth_object = nil)
    %w(user)
  end
end
