require 'rails_helper'

RSpec.describe User, type: :model do
  describe "有効な場合" do
    it "保存できる" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "デフォルトは公開" do
      user = build(:user)
      expect(user.is_private).to be false
    end
  end

  describe "無効な場合" do
    it "メールがユニークでない" do
      user1 = create(:user)
      user2 = build(:user)
      user2.email = user1.email
      user2.valid?
      expect(user2.errors[:email]).to include('はすでに存在します')
    end

    it "メールアドレスが入力されていない" do
      user = build(:user)
      user.email = nil
      user.valid?
      expect(user.errors[:email]).to include('を入力してください')
    end

    it "ユーザーネームが入力されていない" do
      user = build(:user)
      user.name = nil
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end

    it "ユーザーネームは20文字以下でない" do
      user = build(:user)
      user.name = "a" * 21
      user.valid?
      expect(user.errors[:name]).to include('は20文字以内で入力してください')
    end

    it "パスワードが入力されていない" do
      user = build(:user)
      user.password = nil
      user.valid?
      expect(user.errors[:password]).to include('を入力してください')
    end

    it "パスワード確認が入力されていない" do
      binding.pry
      user = build(:user)
      user.password_confirmation = nil
      user.valid?
      expect(user.errors[:password_confirmation]).to include('を入力してください')
    end

    it "パスワード確認とパスワードが一致しない" do
      user = build(:user)
      user.password_confirmation = "PassWord"
      user.valid?
      expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
    end

    it "プロフィールが200文字以下でない" do
      text = "a" * 201
      user = build(:user, profile: text)
      user.valid?
      expect(user.errors[:profile]).to include("は200文字以内で入力してください")
    end
  end

  describe "パスワードバリデーションのスキップ条件" do
    it "nameが存在しており、profileとis_privateだけ変更する場合、passwordなしで保存できる" do
      user = create(:user, name: "テストユーザー", password: "password", password_confirmation: "password")

      # nameはそのまま、profileとis_privateだけ変更
      user.profile = "新しいプロフィール"
      user.is_private = true

      expect(user).to be_valid
    end

    it "nameが空で、passwordがnilの場合は無効になる" do
      user = create(:user, name: "test", password: "password", password_confirmation: "password")
      user.name = ""
      user.password = nil
      user.password_confirmation = nil

      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end
  end

  describe "投稿機能" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:post1) { create(:post, user: user1) }
    let(:post2) { create(:post, user: user2) }

    describe "#post?" do
      it "自分の投稿であればtrueを返す" do
        expect(user1.post?(post1)).to be true
      end

      it "自分の投稿でなければfalseを返す" do
        expect(user1.post?(post2)).to be false
      end
    end
  end

  describe "いいね機能" do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    describe "#like" do
      it "投稿をいいねできる" do
        expect {
          user.like(post)
        }.to change { user.like_posts.include?(post) }.from(false).to(true)
      end
    end

    describe "#unlike" do
      it "投稿のいいねを解除できる" do
        user.like(post)
        expect {
          user.unlike(post)
        }.to change { user.like_posts.include?(post) }.from(true).to(false)
      end
    end

    describe "#like?" do
      it "いいね済みの投稿に対してtrueを返す" do
        user.like(post)
        expect(user.like?(post)).to be true
      end

      it "いいねしていない投稿に対してfalseを返す" do
        expect(user.like?(post)).to be false
      end
    end
  end

  describe "フォロー機能" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    describe "#follow" do
      it "フォローできる" do
        expect {
          user1.follow(user2)
        }.to change { user1.following.include?(user2) }.from(false).to(true)
      end
    end

    describe "#unfollow" do
      it "フォローを外すことができる" do
        user1.follow(user2)
        expect {
          user1.unfollow(user2)
        }.to change { user1.following.include?(user2) }.from(true).to(false)
      end
    end

    describe "#following?" do
      it "フォロー中の場合はtrueを返す" do
        user1.follow(user2)
        expect(user1.following?(user2)).to be true
      end

      it "フォローしていない場合はfalseを返す" do
        expect(user1.following?(user2)).to be false
      end
    end

    describe "#follower?" do
      it "フォロワーの場合はtrueを返す" do
        user1.follow(user2)
        expect(user2.follower?(user1)).to be true
      end

      it "フォロワーでない場合はfalseを返す" do
        expect(user2.follower?(user1)).to be false
      end
    end
  end

  describe "フォローリクエスト送信機能" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user, is_private: true) }
    describe "#send_request" do
      it "フォローリクエストを送信できる" do
        expect {
          user1.send_request(user2)
      }.to change { user1.requested_users.include?(user2) }.from(false).to(true)
      end
    end

    describe "#destroy_request" do
      it "自分が送信したフォローリクエストを取り消せる" do
        user1.send_request(user2)
        expect {
          user1.destroy_request(user2)
        }.to change { user1.requested_users.include?(user2) }.from(true).to(false)
      end
    end

    describe "#request?" do
      it "フォローリクエストを送信した場合はtrueになる" do
        user1.send_request(user2)
        expect(user1.request?(user2)).to be true
      end
    end

    describe "#received_request?" do
      it "フォローリクエストを受け取った場合はtrueになる" do
        user1.send_request(user2)
        expect(user2.received_request?(user1)).to be true
      end
    end

    describe "#sent_follow_request" do
      it "フォローリクエストを送った場合はFollowRequestオブジェクトが返る" do
        user1.send_request(user2)
        request = user1.sent_follow_request(user2)
        expect(request).to be_present
        expect(request.requestee).to eq(user2)
      end
    end

    describe "#received_follow_request" do
      it "フォローリクエストを受け取った場合はフォローリクエストを取得できる" do
        user1.send_request(user2)
        received = user2.received_follow_request(user1)
        expect(received).to be_present
        expect(received.requester).to eq(user1)
      end
    end

    describe "#reject_request" do
      it "フォローリクエストを拒否できる" do
        user1.send_request(user2)
        expect {
          user2.reject_request(user1)
          }.to change { FollowRequest.count }.by(-1)
      end
    end

    describe "#accept_request" do
      it "フォローリクエストを受け入れるとフォローが作成され、リクエストが削除される" do
        user1.send_request(user2)
        expect {
          user2.accept_request(user1)
        }.to change { Follow.count }.by(1)
         .and change { FollowRequest.count }.by(-1)
        expect(user1.following?(user2)).to be true
      end
    end
  end

  describe "通知機能" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:post) { create(:post, user: user2) }
    let(:like) { create(:like, post: post, user: user1) }

    describe "#create_notification" do
      it "userに対し通知を作成できる" do
        expect {
          user2.create_notification(like)
      }.to change { Notification.count }.by(1)
      end
    end

    describe "#unread_notifications_count" do
      it "通知をカウントできる" do
        user2.create_notification(like)
        expect(user2.unread_notifications_count).to eq(1)
      end
    end

    describe "#mark_all_notifications_as_read" do
      it "通知を既読にする" do
        user2.create_notification(like)
        expect {
          user2.mark_all_notifications_as_read
        }.to change { user2.notifications.where(read: true).count  }.by(1)
      end
    end
  end
end
