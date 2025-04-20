class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[accept reject cancel]

  # フォローリクエストを承認
  def accept
    # フォロー承認＋レコードを削除
    current_user.accept_request(@follow_request.requester_id)
    redirect_to request.referer || root_path , success: "フォローリクエストを承認しました", status: :see_other
  end

  # フォローリクエストを拒否
  def reject
    current_user.destroy_request(@follow_request.requester_id)
    redirect_to request.referer || root_path , success: "フォローリクエストを拒否しました", status: :see_other
  end

  # フォローリクエストをキャンセル
  def cancel
    # 自分が送ったリクエストをキャンセル
    current_user.destroy_request(@follow_request.requestee_id)
    redirect_to request.referer || root_path , success: "フォローリクエストをキャンセルしました", status: :see_other
  end

  private
  def set_follow_request
    @follow_request = FollowRequest.find(params[:follow_request_id])
    @user = User.find(@follow_request.requester_id)
  end
end
