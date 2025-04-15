class SearchsController < ApplicationController
  def index
    @users = []
    @posts = []
  end

  def search_users
    @users = []
    @posts = []
    if params[:search].present?
      @users = User.search_by_name(params[:search])
    end
    render :index
  end

  def search_posts
    @users = []
    @posts = []
    if params[:search].present?
      @posts = Post.includes(:user).search_by_content(params[:search])
    end
    render :index
  end
end
