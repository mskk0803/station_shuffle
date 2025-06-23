class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit show update posts likes checkins following_user followers_user]

  def show
    redirect_to profile_posts_path(@user.id)
  end

  def edit
    if @user == current_user
      @user = current_user
    else
      flash[:alert] = "他のユーザーのプロフィールは編集できません。"
      redirect_to profile_posts_path(@user.id)
    end
  end

  def update
    if @user == current_user
      if @user.update(profile_params)
        flash[:notice] = "プロフィールの更新に成功しました。"
        redirect_to profile_posts_path(current_user.id)
      else
        flash[:alert] = "プロフィールの更新に失敗しました。"
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "他のユーザーのプロフィールは更新できません。"
      redirect_to profile_posts_path(@user.id)
    end
  end

  def posts
    @posts = @user.posts.order(created_at: :desc).page(params[:page]).per(5)
    render :show
  end

  def likes
    @likes = @user.like_posts.order(created_at: :desc).page(params[:page]).per(5)
    render :show
  end

  def checkins
    if @user == current_user
      @checkins = @user.checkins.order(created_at: :desc)
      render :show
    else
      flash[:alert] = "他のユーザーのチェックインは表示できません。"
      redirect_to profile_posts_path(@user.id)
    end
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
