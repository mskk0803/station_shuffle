class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    like = current_user.like(post)

    # 通知を作成
    post.user.create_notification(like)
    # もといた画面に遷移する
    # 参考URL:https://qiita.com/sew_sou19/items/21974ec512c0a9b329aa
    redirect_to request.referer || root_path, success: "Like Post"
  end

  def destroy
    post = current_user.likes.find(params[:id]).post
    current_user.unlike(post)
    redirect_to request.referer || root_path, success: "Like Delete", status: :see_other
  end
end
