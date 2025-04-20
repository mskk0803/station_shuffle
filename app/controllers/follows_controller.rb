class FollowsController < ApplicationController
  def create
    user = User.find(params[:id])

    if user.is_private?
      # 非公開ユーザーにフォローリクエストを送信
      current_user.send_request(user)
      redirect_to profile_posts_path(user.id), success: "フォローリクエストを送りました"
    else
      current_user.follow(user)
      redirect_to profile_posts_path(user.id), success: "フォローしました"
    end
  end

  def destroy
    user = current_user.following.find(params[:id])
    current_user.unfollow(user)
    redirect_to profile_posts_path(user.id), success: "フォローを外しました", status: :see_other
  end
end
