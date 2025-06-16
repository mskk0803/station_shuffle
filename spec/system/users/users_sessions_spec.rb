require 'rails_helper'

RSpec.describe "Users::Sessions", type: :system do

  let(:user) { create(:user) }

  describe "#new" do
    it "ログインページが表示される" do
      visit new_user_session_path
      expect(page).to have_content("ログイン")
      expect(page).to have_field("user[email]")
      expect(page).to have_field("user[password]")
      expect(page).to have_field("user[remember_me]")
      expect(page).to have_button("ログイン")
      expect(page).to have_link("新規登録")
      expect(page).to have_link("パスワードをお忘れの方はこちら")
      expect(page).to have_button("Sign in with Google")
    end
  end

  describe "#create" do
    it "ログイン後はpost_pathにリダイレクトする" do
      visit new_user_session_path
      fill_in "Email", with: "#{user.email}"
      fill_in "パスワード", with: "#{user.password}"
      click_button "ログイン"
      expect(page).to have_current_path(following_index_posts_path)
      expect(current_path).to eq(following_index_posts_path)
    end
  end
end
