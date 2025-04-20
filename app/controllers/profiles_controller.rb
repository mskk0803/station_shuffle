class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: %i[show]
  before_action :set_user, only: %i[show posts likes checkins]

  def show

    redirect_to profile_posts_path(@user.id)
  end

  def edit
    @user = current_user
  end

  def update
    user = current_user
    if user.update(profile_params)
      flash[:notice] = "Profile updated successfully"
      redirect_to profile_posts_path(current_user.id)
    else
      flash[:alert] = "Failed to update profile"
      render :edit
    end
  end

  def posts
    @posts = @user.posts.order(created_at: :desc)
    render :show
  end

  def likes
    @likes = @user.like_posts
    render :show
  end

  def checkins
    @checkins = @user.checkins.order(created_at: :desc)
    render :show
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
    params.require(:user).permit(:name, :profile)
  end
end
