require 'rails_helper'

RSpec.describe Post, type: :model do
  context "バリデーションチェック" do
    it "設定した全てのバリデーションが機能しているか" do
      post = create(:post)
      expect(post).to be_valid
    end

    it "コメントがない場合" do
      post = build(:post, content: nil)
      expect(post).to be_invalid
      expect(post.errors[:content]).to include('を入力してください')
    end
  end
end
