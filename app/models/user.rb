class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :checkins, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_posts, through: :likes, source: :post
  has_many :follows, foreign_key: :follows_user_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed
  has_many :reverse_of_follows, foreign_key: :followed_user_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :reverse_of_follows, source: :follower

  validates :name, presence: true
  validates :email, presence: true

  # 検索用スコープ
  scope :search_by_name, ->(name) {
    where("name LIKE ?", "%#{sanitize_sql_like(name)}%") if name.present?
  }

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

  # フォローしたりされたりするときの機能
  def follow(user)
    following << user
  end

  def unfollow(user)
    following.destroy(user)
  end

  def following?(user)
    following.include?(user)
  end

  def follower?(user)
    followers.include?(user)
  end
end
