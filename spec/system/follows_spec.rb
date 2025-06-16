require 'rails_helper'

RSpec.describe "Follows", type: :system do
  # プロフィールページからのみ可能
  # プロフィールページのボタンを押下する想定

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:private_user) { create(:user, is_private: true)}

  describe "#create" do
    before do
      sign_in(user)
    end
    context "公開ユーザーをフォローしていない場合" do
      it "フォローできる" do
        visit profile_path(another_user)
        # フォローが一つ増える
        expect {
          click_button "フォロー"
          expect(page).to have_button("フォロー中")
        }.to change{ user.follows.count }.by(1)
      end

      it "フォロー通知が作成される" do
        visit profile_path(another_user)
        # 通知タイプフォローが一つ増える
        expect {
          click_button "フォロー"
          expect(page).to have_button("フォロー中")
        }.to change{ another_user.notifications.count }.by(1)
      end
    end
    context "非公開ユーザーをフォローしていない場合" do
      it "フォローリクエストが作成される" do
        visit profile_path(private_user)
        # フォローリクエストが一つ増える
        expect {
          click_button "フォロー"
          expect(page).to have_button("リクエスト中")
        }.to change{ user.follow_requests.count }.by(1)
      end

      it "通知が作成される" do
        visit profile_path(private_user)
        # 通知が一つ増える
        expect {
          click_button "フォロー"
          expect(page).to have_button("リクエスト中")
        }.to change{ private_user.notifications.count }.by(1)
      end
    end
  end
  describe "#destroy" do
    before do
      sign_in(user)
      user.follow(another_user)
    end
    context "フォローしている場合" do
      it "フォローを解除できる" do
        # フォローが一つ減る
        visit profile_path(another_user)
        expect {
          click_button "フォロー中"
          expect(page).to have_button("フォロー")
        }.to change{ user.follows.count }.by(-1)
      end
    end
  end
end
