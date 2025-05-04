require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }

  describe "有効な場合" do
    it "保存できる" do
      post = build(:post, user: user)
      expect(post).to be_valid
    end

    it "User削除時に同時に削除される" do
      post = create(:post, user: user)
      expect { user.destroy }.to change { Post.count }.by(-1)
    end

    it "255文字以内で入力できる" do
      text = "a" * 255
      post = build(:post, user: user, content: text)
      expect(post).to be_valid
    end
  end

  describe ".search_by_content" do
    let!(:post1) { create(:post, user: user, content: "渋谷でランチ") }
    let!(:post2) { create(:post, user: user, content: "新宿でカフェ") }
    let!(:post3) { create(:post, user: user, content: "大阪観光") }

    context "検索ワードがある場合" do
      it "部分一致する投稿を返す" do
        results = Post.search_by_content("渋谷")
        expect(results).to include(post1)
        expect(results).not_to include(post2, post3)
      end
    end

    context "検索ワードが空の場合" do
      it "全ての投稿を返す or nilを返す（定義による）" do
        results = Post.search_by_content("")
        expect(results).to include(post1, post2, post3)
      end
    end
  end

  describe "無効な場合" do
    it "コメントがない場合保存できない" do
      post = build(:post, user: user, content: nil)
      expect(post).to be_invalid
      expect(post.errors[:content]).to include('を入力してください')
    end

    it "userがない場合保存できない" do
      post = build(:post, user: nil)
      expect(post).to be_invalid
    end

    it "contentに256文字以上入力できない" do
      text = "a" * 256
      post = build(:post, user: user, content: text)
      expect(post).not_to be_valid
    end
  end
end
