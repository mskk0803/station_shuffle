class FollowsController < ApplicationController
  def create
    @user = User.find(params[:id])

    if @user.is_private?
      # 非公開ユーザーにフォローリクエストを送信
      current_user.send_request(@user)
      follow_request = current_user.follow_requests.find_by(requestee_id: @user.id)
      # 通知を作成
      @user.create_notification(follow_request)
      redirect_to profile_posts_path(@user.id), notice: "フォローリクエストを送りました。。"
    else
      current_user.follow(@user)
      follow = current_user.follows.find_by(followed_user_id: @user.id)

      # 通知を作成
      @user.create_notification(follow)

      # turboで表示
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @user }
      end
    end
  end

  def destroy
    @user = current_user.following.find_by(id: params[:id])
    current_user.unfollow(@user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user }
    end
  end
end
