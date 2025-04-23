class Station
  # DBには保存しないけどバリデーションように必要な処理
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :latitude, :longitude

  validates :name, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
end
