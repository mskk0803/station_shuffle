class Checkin < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :station, presence: true
end
