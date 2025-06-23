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
    @post = current_user.posts.build(post_params)
    @stations = current_user.checkins.order(created_at: :desc).limit(5).pluck(:station).uniq

    if @post.save
      # 後で変更
      redirect_to posts_path, notice: "投稿しました！"
    else
      flash.now[:alert] = "投稿に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    post = Post.find(params[:id])
    if post.user == current_user
      post.destroy
      redirect_to posts_path, notice: "投稿を削除しました。", status: :see_other
    else
      redirect_to posts_path, alert: "他のユーザーの投稿は削除できません。"
    end
  end

  # フォローしているユーザーの投稿を表示するアクション
  def following_index
    users_ids = current_user.following_ids.append(current_user.id)
    @posts = Post.joins(:user)
                .where(users: { id: users_ids })
                .includes(:user)
                .order(created_at: :desc)
                .page(params[:page]).per(5)
    # @my_post_ids = current_user.posts.pluck(:id)
    # @my_like_post_ids = current_user.like_posts.pluck(:id)
    render :index
  end

  # フォローしていないユーザーの投稿を表示するアクション
  # フォローしていない非公開ユーザーを含めない
  def all_index
    current_user_id = current_user.id
    public_user_ids = User.where(is_private: false).pluck(:id)
    following_user_ids = current_user.following_ids
    users_ids = (public_user_ids + following_user_ids).uniq.append(current_user_id)
    @posts = Post.joins(:user)
                .where(users: { id: users_ids })
                .includes(:user)
                .order(created_at: :desc)
                .page(params[:page]).per(5)
    # @my_post_ids = current_user.posts.pluck(:id)
    # @my_like_post_ids = current_user.like_posts.pluck(:id)
    render :index
  end

  private

  def post_params
    params.require(:post).permit(:content, :image, :image_cache, :station)
  end
end
