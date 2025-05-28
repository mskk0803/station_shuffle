require 'rails_helper'

RSpec.describe "Searchs", type: :system do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }
  let(:another_user) { create(:user, name: "別ユーザー") }
  let(:another_post) { create(:post, user: another_user, content: "別ユーザーの投稿") }

  describe "#index" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      it "search_users_searchs_pathにリダイレクトされる" do
        visit searchs_path
        expect(page).to have_current_path(search_users_searchs_path)
      end
    end
    context "ログインしていない場合" do

      it "ログインページにリダイレクトされる" do
        visit searchs_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#search_users" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      it "検索フォームが表示される" do
        visit search_users_searchs_path
        expect(page).to have_content("検索")
        expect(page).to have_field(name: "search")
        expect(page).to have_button("検索")
        expect(page).to have_link("投稿")
        expect(page).to have_link("ユーザー")
      end

      it "ユーザーが存在する場合はユーザーの検索結果が表示される" do
        visit search_users_searchs_path
        fill_in "search", with: another_user.name
        click_button "検索"
        expect(page).to have_content(another_user.name)
      end

      it "ユーザーが存在しない場合は「ユーザーが見つかりません」と表示される" do
        visit search_users_searchs_path
        fill_in "search", with: "存在しないユーザー"
        click_button "検索"
        expect(page).to have_content("ユーザーが見つかりません")
      end
    end
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        visit search_users_searchs_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#search_posts" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        post
        another_user
        another_post
      end
      it "投稿が存在する場合はユーザーの検索結果が表示される" do
        visit search_posts_searchs_path
        fill_in "search", with: another_post.content
        click_button "検索"
        click_link("投稿", match: :first)
        expect(page).to have_content(another_post.content)
      end

      it "投稿が存在しない場合は「投稿が見つかりません」と表示される" do
        visit search_posts_searchs_path
        fill_in "search", with: "存在しない投稿"
        click_button "検索"
        click_link("投稿", match: :first)
        expect(page).to have_content("投稿が見つかりません")
      end
    end
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        visit search_posts_searchs_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#auto_complete" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      it "ユーザー名のオートコンプリートが機能する" do
        visit search_users_searchs_path
        fill_in "search", with: another_user.name
        expect(page).to have_content(another_user.name)
      end
    end
  end
end
