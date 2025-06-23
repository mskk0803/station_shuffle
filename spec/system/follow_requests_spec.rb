require 'rails_helper'

RSpec.describe "FollowRequests", type: :system do
  let(:user) { create(:user) }
  let(:private_user) { create(:user) }

  before do
    sign_in(user)
    # フォローリクエストを作成
    user.send_request(private_user)
    sign_out(user)
  end

  describe "#accept" do
    before do
      sign_in(private_user)
    end
    it "ユーザーがフォローできる" do
      visit profile_path(user)
      expect {
        click_button "承認"
        expect(page).not_to have_button "承認"
      }.to change { user.follows.count }.by(1)
    end

    it "承認後はフォローリクエストテーブルから消える" do
      visit profile_path(user)
      expect {
        click_button "承認"
        expect(page).not_to have_button "承認"
      }.to change { user.requested_users.count }.by(-1)
    end
  end

  describe "#reject" do
    before do
      sign_in(private_user)
    end

    it "フォローリクエストを拒否できる" do
      visit profile_path(user)
      expect {
        click_button "拒否"
        expect(page).not_to have_button "拒否"
      }.to change { user.follows.count }.by(0)
    end

    it "拒否後はフォローリクエストテーブルから消える" do
      visit profile_path(user)
      expect {
        click_button "拒否"
        expect(page).not_to have_button "拒否"
      }.to change { user.requested_users.count }.by(-1)
    end
  end

  describe "#cancel" do
    before do
      sign_in(user)
    end

    it "送ったフォローリクエストを取り消せる" do
      visit profile_path(private_user)
      expect {
        click_button "リクエスト中"
        expect(page).to have_button "フォロー"
      }.to change { user.follows.count }.by(0)
    end

    it "キャンセル後はフォローリクエストテーブルから消える" do
      visit profile_path(private_user)
      expect {
        click_button "リクエスト中"
        expect(page).to have_button "フォロー"
      }.to change { user.requested_users.count }.by(-1)
    end
  end
end
