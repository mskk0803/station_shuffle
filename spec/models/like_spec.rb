require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:post1) { create(:post, user_id: user1.id) }
  let(:post2) { create(:post, user_id: user2.id) }

  describe "全てのフィールドが有効な場合" do
    it "有効であること" do
      like = build(:like, user: user1, post: post2)
      expect(like).to be_valid
    end

    it "User削除時にLikeも削除されること" do
      create(:like, user: user1, post: post2)
      expect { user1.destroy }.to change { Like.count }.by(-1)
    end

    it "Post削除時にLikeも削除されること" do
      create(:like, user: user1, post: post2)
      expect { post2.destroy }.to change { Like.count }.by(-1)
    end
  end

  describe "無効な場合" do
    it "userがnilの場合は無効であること" do
      like = build(:like, user: nil, post: post2)
      expect(like).not_to be_valid
    end

    it "post_idがnilの場合は無効であること" do
      like = build(:like, user: user1, post: nil)
      expect(like).not_to be_valid
    end

    it "ユーザーとの組み合わせがユニークでない場合" do
      like1 = create(:like)
      like2 = build(:like, user: like1.user, post: like1.post)
      like2.valid?
      expect(like2.errors[:user_id]).to include('はすでに存在します')
    end

    it "自分の投稿をいいねできない" do
      like = build(:like, user: user1, post: post1)
      expect(like).not_to be_valid
    end
  end
end
