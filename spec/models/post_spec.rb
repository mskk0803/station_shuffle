require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "有効な場合" do
    let(:user){ create(:user) }
    let(:post){ create(:post, user: user) }

    it "保存できる" do
      post = build(:post, user: user)
      expect(post).to be_valid
    end

    it "User削除時に同時に削除される" do
      post = create(:post, user: user)
      expect { user.destroy }.to change { Post.count }.by(-1)
    end
  end

  describe "無効な場合" do
    let(:user){ create(:user) }
    let(:post){ create(:post, user: user) }

    it "コメントがない場合" do
      post = build(:post, user: user, content: nil)
      expect(post).to be_invalid
      expect(post.errors[:content]).to include('を入力してください')
    end

    it "userがない場合" do
      post = build(:post, user: nil)
      expect(post).to be_invalid
    end
  end
end
