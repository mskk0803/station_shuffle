require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }
  let(:following_user) { create(:user)}
  let(:following_post) { create(:post, user: following_user, content: "フォロー中") }
  let(:another_user) { create(:user) }
  let(:another_post) { create(:post, user: another_user, content: "フォロー中の非公開ユーザー") }
  let(:private_user) { create(:user, is_private: true) }
  let(:private_post) { create(:post, user: private_user, content: "フォローしていない") }
  let(:another_private_user) { create(:user, is_private: true) }
  let(:another_private_post) { create(:post, user: another_private_user, content: "フォローしていない非公開ユーザー") }

  describe "#index" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      it "following_index_posts_pathにリダイレクトされる" do
        visit posts_path
        expect(page).to have_current_path(following_index_posts_path)
      end

      it "下部リンクから投稿一覧ページにアクセスできる" do
        visit root_path
        click_link "投稿"
        expect(page).to have_current_path(following_index_posts_path)
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit posts_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#new" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      it "新しい投稿フォームが表示される" do
        visit new_post_path
        expect(page).to have_content("到着報告")
        expect(page).to have_content("最近のチェックイン駅")
        expect(page).to have_content("コメント")
        expect(page).to have_content("写真をアップロード")
        expect(page).to have_field("post_content")
        expect(page).to have_button("報告！")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit new_post_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#create" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end

      it "新しい投稿を作成できる" do
        visit new_post_path
        fill_in "コメント", with: "新しい投稿内容"
        click_button "報告！"
        expect(page).to have_current_path(following_index_posts_path)
      end

      it "投稿に画像を添付できる" do
        visit new_post_path
        fill_in "コメント", with: "新しい投稿内容"
        file_path = Rails.root.join("spec/fixtures/example.jpg")
        attach_file "写真をアップロード", file_path
        click_button "報告！"
        expect(page).to have_current_path(following_index_posts_path)
        # リダイレクト後の処理
        expect(current_path).to eq(following_index_posts_path)
        expect(page).to have_content("投稿しました！")
      end
    end

    context "バリデーションエラーがある場合" do
      before do
        sign_in(user)
      end
      it "コメントが空の場合、エラーメッセージが表示される" do
        visit new_post_path
        fill_in "コメント", with: ""
        click_button "報告！"
        expect(page).to have_content("投稿に失敗しました。")
        expect(page).to have_current_path(new_post_path)
      end
    end
  end

  describe "#destroy" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        # 事前に投稿を作成しておく
        post
      end
      it "自分の投稿を削除できる" do
        visit following_index_posts_path
        click_button "削除"
        expect(page).to have_current_path(following_index_posts_path)
      end
    end
  end

  describe "#following_index" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end

      it "自分の投稿が表示される" do
        # 自分の投稿を作成
        post

        visit following_index_posts_path
        expect(page).to have_content(post.content)
      end

      it "フォロー中のユーザーの投稿が表示される" do
        # フォロー中のユーザーとその投稿を作成
        following_user
        following_post

        # フォローする
        user.follow(following_user)

        visit following_index_posts_path
        expect(page).to have_content(following_post.content)
      end

      it "フォロー中の非公開ユーザーの投稿が表示される" do
        # 非公開ユーザーとその投稿を作成
        private_user
        private_post
        # 非公開ユーザーをフォローする
        user.follow(private_user)

        visit following_index_posts_path
        expect(page).to have_content(private_post.content)
      end

      it "フォローしていないユーザーの投稿は表示されない" do
        # フォローしていないユーザーとその投稿を作成
        another_user
        another_post

        visit following_index_posts_path
        expect(page).not_to have_content(another_post.content)
      end

      it "フォローしていない非公開ユーザーの投稿は表示されない" do
        # フォローしていない非公開ユーザーとその投稿を作成
        another_private_user
        another_private_post

        visit following_index_posts_path
        expect(page).not_to have_content(another_private_post.content)
      end

      it "自分の投稿には削除ボタンが表示される" do
        # 自分の投稿を作成
        post

        visit following_index_posts_path
        expect(page).to have_button("削除")
      end

      it "自分以外の投稿には削除ボタンは表示されない" do
        # 自分以外の投稿を作成
        following_user
        following_post
        user.follow(following_user)

        visit following_index_posts_path
        expect(page).not_to have_button("削除")
      end

      it "自分の投稿にはいいねボタンが表示されない" do
        # 自分の投稿を作成
        post
        visit following_index_posts_path
        expect(page).not_to have_selector("button#like-#{post.id}")
      end

      it "自分以外の投稿にはいいねボタンが表示される" do
        # 自分以外の投稿を作成
        following_user
        following_post
        user.follow(following_user)

        visit following_index_posts_path
        expect(page).to have_selector("button#like-#{following_post.id}")
      end

      it "いいねボタンが押された場合、いいねができる" do
        # 自分以外の投稿を作成
        following_user
        following_post
        user.follow(following_user)

        visit following_index_posts_path
        find("#like-#{following_post.id}").click
        expect(page).to have_selector("button#unlike-#{following_post.id}")
      end

      it "いいねボタンが押された場合、いいねが解除できる" do
        # 自分以外の投稿を作成
        following_user
        following_post
        user.follow(following_user)

        # いいねをする
        user.like(following_post)
        visit following_index_posts_path
        find("#unlike-#{following_post.id}").click
        expect(page).to have_selector("button#like-#{following_post.id}")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit following_index_posts_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#all_index" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      it "フォローしていない非公開ユーザー以外のすべてのユーザーの投稿が表示される" do
        # 自分の投稿を作成
        post
        # フォロー中のユーザーとその投稿を作成
        following_user
        following_post
        # フォローする
        user.follow(following_user)

        # 非公開ユーザーとその投稿を作成
        private_user
        private_post
        # 非公開ユーザーをフォローする
        user.follow(private_user)

        # フォローしていないユーザーとその投稿を作成
        another_user
        another_post

        # フォローしていない非公開ユーザーとその投稿を作成
        another_private_user
        another_private_post

        visit all_index_posts_path
        expect(page).to have_content(post.content)
        expect(page).to have_content(following_post.content)
        expect(page).to have_content(private_post.content)
        expect(page).to have_content(another_post.content)
        expect(page).not_to have_content(another_private_post.content)
      end

      it "自分の投稿には削除ボタンが表示される" do
        # 自分の投稿を作成
        post

        visit all_index_posts_path
        expect(page).to have_button("削除")
      end

      it "自分以外の投稿には削除ボタンは表示されない" do
        # 自分以外の投稿を作成
        following_user
        following_post
        user.follow(following_user)

        visit all_index_posts_path
        expect(page).not_to have_button("削除")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit all_index_posts_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
