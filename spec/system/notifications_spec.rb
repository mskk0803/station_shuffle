require 'rails_helper'

RSpec.describe "Notifications", type: :system do
  let(:user) { create(:user) }
  let(:my_post) { create(:post, user: user) }
  let(:another_user) { create(:user, name: "別ユーザー") }

  describe "#index" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      it "公開アカウントの通知一覧ページが表示される" do
        # いいね、フォロー
        another_user.follow(user)
        follow = another_user.follows.find_by(followed_user_id: user.id)
        user.create_notification(follow)

        another_user.like(my_post)
        like = another_user.likes.find_by(post_id: my_post.id)
        user.create_notification(like)

        visit notifications_path

        expect(page).to have_content("通知")
        expect(page).to have_link("#{another_user.name}")
        expect(page).to have_link("#{another_user.name}")
      end
      it "非公開アカウントの通知一覧ページが表示される" do
        # フォローリクエスト
        user.update(is_private: true)
        another_user.send_request(user)

        follow_request = another_user.follow_requests.find_by(requestee_id: user.id)
        # 通知を作成
        user.create_notification(follow_request)

        visit notifications_path

        expect(page).to have_content("通知")
        expect(page).to have_link("#{another_user.name}")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit notifications_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
