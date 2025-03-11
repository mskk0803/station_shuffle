class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def create
    post = current_user.posts.build(post_params)

    if post.save!
      # 後で変更
      redirect_to posts_path, success: "Post created successfully"
    else
      flash.now[:danger] = "Post creation failed"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to posts_path, success: "Post deleted successfully", status: :see_other
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
