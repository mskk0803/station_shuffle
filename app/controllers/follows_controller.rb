class FollowsController < ApplicationController
  def create
    user = User.find(params[:id])

    if user.is_private?
      # 非公開ユーザーにフォローリクエストを送信
      current_user.send_request(user)
      redirect_to profile_posts_path(user.id), success: "フォローリクエストを送りました"
    else
      current_user.follow(user)
      follow = current_user.follows.find_by(followed_user_id: user.id)

      # 通知を作成
      user.create_notification(follow)
      redirect_to profile_posts_path(user.id), success: "フォローしました"
    end
  end

  def destroy
    user = current_user.following.find_by(id: params[:id])
    current_user.unfollow(user)
    redirect_to profile_posts_path(user.id), success: "フォローを外しました", status: :see_other
  end
end
