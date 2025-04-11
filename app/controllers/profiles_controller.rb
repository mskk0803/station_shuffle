class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: %i[show]
  before_action :set_user, only: %i[posts likes checkins]

  def show
    redirect_to profile_posts_path(current_user.id)
  end

  def edit
  end

  def update
  end

  def posts
    @posts = current_user.posts
    render :show
  end

  def likes
    @likes = current_user.likes.includes(:post)
    render :show
  end

  def checkins
    @checkins = current_user.checkins
    render :show
  end

  private
  def set_user
    @user = current_user
  end
end
