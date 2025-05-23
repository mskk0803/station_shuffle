require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe "バリデーションが有効な場合" do
    it "有効な場合は保存できる" do
      follow = build(:follow, follower: user1, followed: user2)
      expect(follow).to be_valid
    end

    it "フォローとフォロワーが逆でも保存できる" do
      follow = create(:follow, follower: user1, followed: user2)
      follow2 = create(:follow, follower: user2, followed: user1)
      expect(follow2).to be_valid
    end
  end
  describe "無効な場合" do
    it "同じユーザーを2回フォローできない（組み合わせがユニークでない）" do
      create(:follow, follower: user1, followed: user2)
      duplicate = build(:follow, follower: user1, followed: user2)
      expect(duplicate).not_to be_valid
    end

    it "自分をフォローできない" do
      follow = build(:follow, follower: user1, followed: user1)
      expect(follow).not_to be_valid
    end
  end
end
