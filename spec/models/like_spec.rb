require 'rails_helper'

RSpec.describe Like, type: :model do
  context "全てのフィールドが有効な場合" do
    it "有効であること" do
      like = build(:like)
      expect(like).to be_valid
    end
  end

  context "ユーザーと投稿の組み合わせがユニークでない場合" do
    it "無効であること" do
      binding.pry
      like1 = create(:like)
      like2 = build(:like, user: like1.user, post: like1.post)
      like2.valid?
      expect(like2.errors[:user_id]).to include('はすでに存在します')
    end
  end
end
