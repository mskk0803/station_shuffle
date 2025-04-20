class PostsController < ApplicationController
  def index
    redirect_to following_index_posts_path
  end

  def new
    # 参考URL:https://tech.hukurouo.com/articles/2021-09-03-rails-form-preset
    @post = Post.new
    if current_user.checkins.empty?
      @post.content = ""
    else
      station = current_user.checkins.last.station
      @post.content = "#{station}に到着！"
    end
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

  # フォローしているユーザーの投稿を表示するアクション
  def following_index
    @posts = Post.includes(:user).where(users: { id: current_user.following_ids + [ current_user.id ] }).order(created_at: :desc)
    render :index
  end

  # フォローしていないユーザーの投稿を表示するアクション
  def all_index
    @posts = Post.all.order(created_at: :desc)
    render :index
  end

  private

  def post_params
    params.require(:post).permit(:content, :image, :image_cache)
  end
end
