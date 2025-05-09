class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: %i[show]
  before_action :set_user, only: %i[show posts likes checkins following_user followers_user]

  def show
    redirect_to profile_posts_path(@user.id)
  end

  def edit
    @user = current_user
  end

  def update
    user = current_user
    if user.update(profile_params)
      flash[:notice] = "プロフィールの更新に成功しました。"
      redirect_to profile_posts_path(current_user.id)
    else
      flash[:alert] = "プロフィールの更新に失敗しました。"
      render :edit
    end
  end

  def posts
    @posts = @user.posts.order(created_at: :desc).page(params[:page]).per(5)
    # @my_post_ids = @user.posts.pluck(:id)
    render :show
  end

  def likes
    @likes = @user.like_posts.order(created_at: :desc).page(params[:page]).per(5)
    # @my_like_post_ids = @user.like_posts.pluck(:id)
    render :show
  end

  def checkins
    @checkins = @user.checkins.order(created_at: :desc)
    render :show
  end

  # フォロー一覧
  def following_user
    @following_users = @user.following
  end

  # フォロワー一覧
  def followers_user
    @followers_users = @user.followers
  end

  private
  def set_user
    # params[:id]がnilの場合はparams[:profile_id]を使用
    if params[:id]
      @user = User.find_by(id: params[:id])
    else
      @user = User.find_by(id: params[:profile_id])
    end
  end

  def profile_params
    params.require(:user).permit(:name, :profile, :is_private)
  end
end
