class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])

    # いいね作成
    current_user.like(post)

    like = current_user.likes.find_by(post_id: post.id)
    # いいねをされたユーザー
    user = post.user
    # 通知を作成
    post.user.create_notification(like)
    # もといた画面に遷移する
    # 参考URL:https://qiita.com/sew_sou19/items/21974ec512c0a9b329aa
    redirect_to request.referer || root_path, success: "いいねしました。"
  end

  def destroy
    post = current_user.likes.find(params[:id]).post
    current_user.unlike(post)
    redirect_to request.referer || root_path, success: "いいねを取り消しました。", status: :see_other
  end
end
