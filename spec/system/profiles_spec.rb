require 'rails_helper'

RSpec.describe "Profiles", type: :system do

  let(:user) { create(:user) }
  let(:my_post) { create(:post, user: user) }
  let(:checkin) { create(:checkin, user: user, station: "東京駅") }
  let(:another_user) { create(:user, name: "別ユーザー") }
  let(:another_post) { create(:post, user: another_user, content: "別ユーザーの投稿") }
  let(:private_user) { create(:user, is_private: true, name: "非公開ユーザー") }
  let(:private_post) { create(:post, user: private_user, content: "非公開ユーザーの投稿") }

  describe "#show" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        my_post
        another_user
        another_post
        private_user
        private_post
      end

      it "フッターのリンクからアクセスできる" do
        visit root_path
        click_link "マイページ"
        expect(page).to have_current_path(profile_posts_path(user))
      end

      it "profile_posts_pathにリダイレクトされる" do
        visit profile_path(user)
        expect(page).to have_current_path(profile_posts_path(user))
      end

      context "自分のプロフィールページにアクセスしたとき" do
        it "自分のプロフィールページが表示される" do
          visit profile_path(user)
          expect(page).to have_content(user.name)
          expect(page).to have_button("編集")
          expect(page).to have_link("フォロー")
          expect(page).to have_link("フォロワー")
          expect(page).to have_link("投稿", match: :first)
          expect(page).to have_link("いいね")
          expect(page).to have_link("チェックイン")
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        context "公開ユーザーの場合" do
          before do
            visit profile_path(another_user)
          end
          it "プロフィールページが表示される" do
            expect(page).to have_content(another_user.name)
            expect(page).to have_button("フォロー")
            expect(page).to have_link("フォロー")
            expect(page).to have_link("フォロワー")
            expect(page).to have_link("投稿", match: :first)
            expect(page).to have_link("いいね")
            expect(page).not_to have_content("チェックイン")
          end
          it "フォローボタンをクリック後、フォロー中と表示される" do
            click_button "フォロー"
            expect(page).to have_button("フォロー中")
          end
        end

        context "非公開ユーザーの場合" do
          before do
            visit profile_path(private_user)
          end
          it "プロフィールページが表示されるが、投稿、いいね、チェックインが表示されない" do
            expect(page).to have_content(private_user.name)
            expect(page).to have_button("フォロー")
            expect(page).to have_link("フォロー")
            expect(page).to have_link("フォロワー")
            expect(page).not_to have_link("投稿", count: 2)
            expect(page).not_to have_link("いいね")
            expect(page).not_to have_link("チェックイン")
          end

          it "フォローボタンをクリック後、リクエスト中と表示される" do
            click_button "フォロー"
            expect(page).to have_button("リクエスト中")
          end
        end
      end

    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit profile_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#edit" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      context "自分のプロフィール編集ページにアクセスしたとき" do
        it "プロフィール編集ページが表示される" do
          visit edit_profile_path(user)
          expect(page).to have_content("登録情報の変更")
          expect(page).to have_field("user_name", with: user.name)
          expect(page).to have_field("プロフィール")
          expect(page).to have_field("プロフィールを非公開にする")
          expect(page).to have_button("更新")
        end
      end
      context "他のユーザーのプロフィール編集ページにアクセスしたとき" do
        it "ほかのユーザーのプロフィールページにリダイレクトされる" do
          visit edit_profile_path(another_user)
          expect(page).to have_current_path(profile_posts_path(another_user))
          expect(page).to have_content("他のユーザーのプロフィールは編集できません。")
        end
      end

    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit edit_profile_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#update" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        visit edit_profile_path(user)
      end

      it "プロフィール情報が更新される" do
        fill_in "user_name", with: "新しい名前"
        fill_in "user_profile", with: "新しいプロフィール"
        check "プロフィールを非公開にする"
        click_button "更新"

        expect(page).to have_current_path(profile_posts_path(user))
        expect(page).to have_content("プロフィールの更新に成功しました。")
      end

      context "バリデーションエラーがある場合" do
        it "プロフィール情報が更新できない" do
          fill_in "user_name", with: ""
          click_button "更新"
          expect(page).to have_content("プロフィールの更新に失敗しました。")
        end
      end
    end
  end

  describe "#posts" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      context "自分のプロフィールページにアクセスしたとき" do
        context "自分の投稿があるとき" do
          before do
            my_post
            visit profile_posts_path(user)
          end
          it "自分の投稿が表示される" do
            expect(page).to have_content(my_post.content)
            expect(page).to have_button("削除", count: 1)
          end

          it "自分の投稿を削除できる" do
            click_button "削除"
            expect(page).to have_current_path(profile_posts_path(user))
            expect(page).not_to have_content(my_post.content)
          end

          it "自分のプロフィールページには人の投稿は表示されない" do
            another_post
            expect(page).not_to have_content(another_post.content)
          end
        end

        context "自分の投稿がないとき" do
          it "何も表示されない" do
            expect(page).to have_content("")
          end
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        context "公開ユーザーの場合" do
          context "他のユーザーの投稿があるとき" do
            before do
              another_post
              visit profile_posts_path(another_user)
            end
            it "他のユーザーの投稿が表示される" do
              expect(page).to have_content(another_post.content)
            end

            it "他のユーザーの投稿に削除ボタンが表示されない" do
              expect(page).not_to have_button("削除")
            end

            it "自分の投稿は表示されない" do
              expect(page).not_to have_content(my_post.content)
            end
          end
          context "他のユーザーの投稿がないとき" do
            it "何も表示されない" do
              visit profile_posts_path(another_user)
              expect(page).to have_content("")
            end
          end
        end
      end

    end
    context "ログインしていない場合" do
      before do
        another_user
        visit profile_posts_path(another_user)
      end
      it "ログイン画面にリダイレクトされる" do
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#likes" do
    context "ログインしている場合" do
      before do
        sign_in(user)
      end
      context "自分のプロフィールページにアクセスしたとき" do
        context "いいねした投稿があるとき" do
          before do
            another_user
            another_post
          end
          it "いいねした投稿が表示される" do
            user.like(another_post)
            visit profile_likes_path(user)
            expect(page).to have_content(another_post.content)
            expect(page).to have_selector("button#unlike-#{another_post.id}")
          end

          it "いいねを削除できる" do
            user.like(another_post)
            visit profile_likes_path(user)
            find("#unlike-#{another_post.id}").click
            visit profile_likes_path(user)
            expect(page).not_to have_content(another_post.content)
          end

          it "いいねしていない投稿は表示されない" do
            expect(page).not_to have_content(another_post.content)
          end
        end
        context "いいねした投稿がないとき" do
          it "何も表示されない" do
            visit profile_likes_path(user)
            expect(page).to have_content("")
          end
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        before do
          another_user
          my_post
        end
        context "いいねした投稿があるとき" do
          it "いいねした投稿が表示される" do
            another_user.like(my_post)
            visit profile_likes_path(another_user)
            expect(page).to have_content(my_post.content)
          end

          it "いいねを削除ボタンが表示されない" do
            another_user.like(my_post)
            visit profile_likes_path(another_user)
            expect(page).not_to have_button("unlike")
          end

          it "いいねしていない投稿は表示されない" do
            visit profile_likes_path(another_user)
            expect(page).not_to have_content(my_post.content)
          end
        end
        context "いいねした投稿がないとき" do
          it "何も表示されない" do
            visit profile_likes_path(another_user)
            expect(page).to have_content("")
          end
        end
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit profile_likes_path(another_user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "checkins" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      context "自分のプロフィールページにアクセスしたとき" do
        context "チェックインがあるとき" do
          it "チェックインが表示される" do
            checkin
            visit profile_checkins_path(user)
            expect(page).to have_content("東京駅")
          end
        end

        context "チェックインがないとき" do
          it "チェックイン履歴はありません。と表示される" do
            visit profile_checkins_path(user)
            expect(page).to have_content("チェックイン履歴はありません。")
          end
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        it "ほかのユーザーのプロフィールページにリダイレクトされる" do
          visit profile_checkins_path(another_user)
          expect(page).to have_current_path(profile_posts_path(another_user))
          expect(page).to have_content("他のユーザーのチェックインは表示できません。")
        end
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit profile_checkins_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#following_user" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      context "自分のプロフィールページにアクセスしたとき" do
        it "自分がフォローしているユーザーが表示される" do
          user.follow(another_user)
          visit profile_following_user_path(user)
          expect(page).to have_content(another_user.name)
        end

        it "フォロー中のユーザーのプロフィールページにアクセスできる" do
          user.follow(another_user)
          visit profile_following_user_path(user)
          click_link another_user.name
          expect(page).to have_current_path(profile_posts_path(another_user))
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        it "ほかのユーザーがフォローしているユーザーが表示される" do
          another_user.follow(user)
          visit profile_following_user_path(another_user)
          expect(page).to have_content(user.name)
        end

        it "フォロー中のユーザーのプロフィールページにアクセスできる" do
          another_user.follow(user)
          visit profile_following_user_path(another_user)
          click_link user.name
          expect(page).to have_current_path(profile_posts_path(user))
        end
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit profile_following_user_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#followers_user" do
    context "ログインしている場合" do
      before do
        sign_in(user)
        another_user
      end
      context "自分のプロフィールページにアクセスしたとき" do
        it "自分をフォローしているユーザーが表示される" do
          another_user.follow(user)
          visit profile_followers_user_path(user)
          expect(page).to have_content(another_user.name)
        end

        it "フォロワーのプロフィールページにアクセスできる" do
          another_user.follow(user)
          visit profile_followers_user_path(user)
          click_link another_user.name
          expect(page).to have_current_path(profile_posts_path(another_user))
        end
      end

      context "他のユーザーのプロフィールページにアクセスしたとき" do
        it "ほかのユーザーをフォローしているユーザーが表示される" do
          user.follow(another_user)
          visit profile_followers_user_path(another_user)
          expect(page).to have_content(user.name)
        end

        it "フォロワーのプロフィールページにアクセスできる" do
          user.follow(another_user)
          visit profile_followers_user_path(another_user)
          click_link user.name
          expect(page).to have_current_path(profile_posts_path(user))
        end
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        visit profile_followers_user_path(user)
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
