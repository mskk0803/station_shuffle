class PostsController < ApplicationController
  def index
    redirect_to following_index_posts_path
  end

  def new
    # 参考URL:https://tech.hukurouo.com/articles/2021-09-03-rails-form-preset
    @post = Post.new
    @stations = current_user.checkins.order(created_at: :desc).limit(5).pluck(:station).uniq
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
    @posts = Post.includes(:user).where(users: { id: current_user.following_ids + [ current_user.id ] }).order(created_at: :desc).page(params[:page]).per(5)
    render :index
  end

  # フォローしていないユーザーの投稿を表示するアクション
  # フォローしていない非公開ユーザーを含めない
  def all_index
    current_user_id = current_user.id
    public_user_ids = User.where(is_private: false).pluck(:id)
    following_user_ids = current_user.following.pluck(:id)
    users_ids = (public_user_ids + following_user_ids).uniq.append(current_user_id)
    @posts = Post.includes(:user).where(user_id: users_ids).order(created_at: :desc).page(params[:page]).per(5)
    render :index
  end

  private

  def post_params
    params.require(:post).permit(:content, :image, :image_cache, :station)
  end
end
