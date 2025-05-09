class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[accept reject cancel]

  # フォローリクエストを承認
  def accept
    # フォロー承認＋レコードを削除
    current_user.accept_request(@user)
    # 通知を作成
    follow = current_user.reverse_of_follows.find_by(follows_user_id: @user.id)

    # 通知を作成
    current_user.create_notification(follow)
    redirect_to profile_posts_path(@user), notice: "フォローリクエストを承認しました"
  end

  # フォローリクエストを拒否
  def reject
    current_user.reject_request(@follow_request.requester_id)
    redirect_to profile_posts_path(@user), notice: "フォローリクエストを拒否しました", status: :see_other
  end

  # フォローリクエストをキャンセル
  def cancel
    # 自分が送ったリクエストをキャンセル
    current_user.destroy_request(@follow_request.requestee_id)
    redirect_to profile_posts_path(@follow_request.requestee_id), notice: "フォローリクエストをキャンセルしました", status: :see_other
  end

  private
  def set_follow_request
    @follow_request = FollowRequest.find(params[:follow_request_id])
    @user = User.find_by(id: @follow_request.requester_id)
  end
end
