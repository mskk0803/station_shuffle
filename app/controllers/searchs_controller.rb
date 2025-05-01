class SearchsController < ApplicationController
  def index
    redirect_to search_users_searchs_path
  end

  def search_users
    @users = []
    @posts = []
    if params[:search].present?
      @users = User.search_by_name(params[:search]).page(params[:page]).per(5)
    end
    render :index
  end

  def search_posts
    @users = []
    @posts = []
    if params[:search].present?
      @posts = Post.includes(:user).search_by_content(params[:search]).page(params[:page]).per(5)
    end
    render :index
  end

  def auto_complete
    @users = []
    if params[:search].present?
      @users = User.search_by_name(params[:search])
    end
    render json: @users.map { |user| { id: user.id, name: user.name } }
  end
end
