require 'rails_helper'

RSpec.describe Notification, type: :model do

  let(:user1){ create(:user) }
  let(:user2){ create(:user) }
  let(:post){ create(:post, user_id: user2.id, content: "notificationtest") }
  let(:like){ create(:like, user_id: user1.id, post_id: post.id)}
  let(:follow){ create(:follow, follower: user1, followed: user2) }
  let(:follow_request){ create(:follow_request, requester: user2, requestee: user1) }

  describe "全てのフィールドが有効な場合" do
    it "Likeの通知が有効であること" do
      notification = build(:like_notification, user: user1, notifable: like)
      expect(notification).to be_valid
    end

    it "Like削除時に削除されること" do
      notification = create(:like_notification, user: user1, notifable: like)
      expect { like.destroy }.to change { Notification.count }.by(-1)
    end

    it "Followの通知が有効であること" do
      notification = build(:follow_notification, user: user1, notifable: follow)
      expect(notification).to be_valid
    end

    it "Followを外したときに削除されること" do
      notification = create(:follow_notification, user: user1, notifable: follow)
      expect { follow.destroy }.to change { Notification.count }.by(-1)
    end

    it "FollowRequestの通知が有効であること" do
      notification = build(:follow_request_notification, user: user1, notifable: follow_request)
      expect(notification).to be_valid
    end

    it "フォローリクエストを削除したときに削除されること" do
      notification = create(:follow_request_notification, user: user1, notifable: follow_request)
      expect { follow_request.destroy }.to change { Notification.count }.by(-1)
    end

    it "新しい通知は未読であること" do
      notification = build(:like_notification, user: user1, notifable: like)
      expect(notification.read).to be_falsey
    end

    it "ユーザー削除時に通知も削除されること" do
      notification = create(:like_notification, user: user1)
      expect { user1.destroy }.to change { Notification.count }.by(-1)
    end
  end

  describe "無効なフィールドがある場合" do
    it "userがnilなら無効になること" do
      notification = build(:like_notification, user: nil, notifable: like)
      expect(notification).not_to be_valid
    end

    it "型がnilなら無効になること" do
      notification = build(:like_notification, user: user1, notifable: nil)
      expect(notification).not_to be_valid
    end

    it "通知タイプがnilなら無効になること" do
      notification = build(:like_notification, user: user1, notifable: like)
      notification.notifable_type = nil
      expect(notification).not_to be_valid
    end
  end

  describe "通知タイプを確認する場合" do
    it "Likeの通知タイプでlike?がtrueになる" do
      notification = build(:like_notification, user: user1, notifable: like)
      expect(notification.like?).to be true
    end

    it "Followの通知タイプでfollow?がtrueになる" do
      notification = build(:follow_notification, user: user1, notifable: follow)
      expect(notification.follow?).to be true
    end

    it "FollowRequestの通知タイプでfollow_request?がtrueになる" do
      notification = build(:follow_request_notification, user: user1, notifable: follow_request)
      expect(notification.follow_request?).to be true
    end

  end
end
