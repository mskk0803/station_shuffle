class Post < ApplicationRecord

  belongs_to :user
  validates :content, presence: true
  validates :uid, presence: true

end
