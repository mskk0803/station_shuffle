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
  has_many :follow_requests, foreign_key: :requester_id, dependent: :destroy
  has_many :requested_users, through: :follow_requests, source: :requestee
  has_many :inverse_follow_requests, foreign_key: :requestee_id, class_name: "FollowRequest", dependent: :destroy
  has_many :requesters, through: :inverse_follow_requests, source: :requester

  validates :name, presence: true
  validates :email, presence: true
  # trueかflaseが含まれているかのバリデーション
  # trueだと非公開、デフォルトはfalse
  validates :is_private, inclusion: { in: [true, false] }

  # 検索用スコープ
  scope :search_by_name, ->(name) {
    where("name LIKE ?", "%#{sanitize_sql_like(name)}%") if name.present?
  }

  # nameとprofile,is_private以外を更新する場合はpasswordとpassword_confirmationを必須にする
  # 参考URL：https://qiita.com/tmzkysk/items/a0c874715ba38eb23350
  with_options unless: -> { :name? || :profile? || :is_private? } do
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

  # フォローリクエストを送信するときの機能
  def send_request(user)
    requested_users << user
  end

  # 自分が送ったリクエストを消す
  def destroy_request(user)
    requested_users.destroy(user)
  end

  # フォローリクエストを送った時の機能
  def request?(user)
    requested_users.include?(user)
  end

  #　受け取ったか？
  def received_request?(user)
    requesters.include?(user)
  end

  # 送ったフォローリクエストの取得
  def sent_follow_request(user)
    follow_requests.find_by(requestee_id: user.id)
  end

  # 受け取ったフォローリクエストの取得
  def received_follow_request(user)
    inverse_follow_requests.find_by(requester_id: user.id)
  end

  # リクエストをうけいれてレコードを消す
  def accept_request(user)
    follow(user)
    destroy_request(user)
  end
end
