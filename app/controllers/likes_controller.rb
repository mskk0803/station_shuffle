class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    current_user.like(post)
    redirect_to posts_path, success: "Like Post"
  end

  def destroy
    post = current_user.likes.find(params[:id]).post
    current_user.unlike(post)
    redirect_to posts_path, success: "Like Delete", status: :see_other
  end
end
