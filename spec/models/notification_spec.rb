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
    describe "#notifable_types" do
    it "正しい通知タイプを返す" do
      notification = Notification.new
      expect(notification.notifable_types).to match_array(%w[Follow Like FollowRequest])
    end
  end

  describe "#valid_notifable_type?" do
    let(:notification) { Notification.new }

    context "有効なタイプの場合" do
      it "Follow は true を返す" do
        expect(notification.valid_notifable_type?("Follow")).to be true
      end

      it "Like は true を返す" do
        expect(notification.valid_notifable_type?("Like")).to be true
      end

      it "FollowRequest は true を返す" do
        expect(notification.valid_notifable_type?("FollowRequest")).to be true
      end

      it "シンボルや小文字でも true を返す（例: :like）" do
        expect(notification.valid_notifable_type?(:like)).to be true
      end
    end

    context "無効なタイプの場合" do
      it "Post は false を返す" do
        expect(notification.valid_notifable_type?("Post")).to be false
      end

      it "nil は false を返す" do
        expect(notification.valid_notifable_type?(nil)).to be false
      end

      it "空文字列は false を返す" do
        expect(notification.valid_notifable_type?("")).to be false
      end
    end
  end

end
