require 'rails_helper'

RSpec.describe FollowRequest, type: :model do
  describe "バリデーション" do
    let(:user1){ create(:user) }
    let(:user2){ create(:user) }
    it "有効な場合は保存できる" do
      follow_request = build(:follow_request, requester: user1, requestee: user2)
      expect(follow_request).to be_valid
    end

    it "お互いにフォローリクエストを送りあうことができる" do
      follow_request = create(:follow_request, requester: user1, requestee: user2)
      follow_request2 = build(:follow_request, requester: user2, requestee: user1)
      expect(follow_request2).to be_valid
    end

    it "同じユーザーに2回フォロリクエストを送信できない（組み合わせがユニークでない）" do
      follow_request = create(:follow_request, requester: user1, requestee: user2)
      duplicate = build(:follow_request, requester: user1, requestee: user2)
      expect(duplicate).not_to be_valid
    end

    it "自分にフォローリクエストを送信できない" do
      follow_request = build(:follow_request, requester: user1, requestee: user1)
      expect(follow_request).not_to be_valid
    end
  end
end
