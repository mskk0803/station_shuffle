class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    current_user.like(post)
    # もといた画面に遷移する
    # 参考URL:https://qiita.com/sew_sou19/items/21974ec512c0a9b329aa
    redirect_to request.referer, success: "Like Post"
  end

  def destroy
    post = current_user.likes.find(params[:id]).post
    current_user.unlike(post)
    redirect_to request.referer, success: "Like Delete", status: :see_other
  end
end
