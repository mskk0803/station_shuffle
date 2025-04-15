class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :checkins, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_posts, through: :likes, source: :post

  validates :name, presence: true
  validates :email, presence: true

  # nameとprofile以外を更新する場合はpasswordとpassword_confirmationを必須にする
  # 参考URL：https://qiita.com/tmzkysk/items/a0c874715ba38eb23350
  with_options unless: -> { :name? || :profile? } do
    validates :password, presence: true
    validates :password_confirmation, presence: true
  end
  validates :profile, length: { maximum: 200 }, allow_blank: true

  # ユーザーがいいねするときの機能
  def like(post)
    like_posts << post
  end

  def unlike(post)
    like_posts.destroy(post)
  end

  def like?(post)
    like_posts.include?(post)
  end

  def post?(post)
    posts.include?(post)
  end

  # 検索用スコープ
  scope :search_by_name, ->(name) {
    where("name LIKE ?", "%#{sanitize_sql_like(name)}%") if name.present?
  }
end
