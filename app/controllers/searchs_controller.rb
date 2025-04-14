class SearchsController < ApplicationController
  def index
    # @q = User.ransack(params[:q])
    # @users = @q.result.includes(:posts)

    @users = []
    @posts = []

    if params[:search].present?
      @users = User.search_by_name(params[:search])
      @posts = Post.includes(:user).search_by_content(params[:search])
    end
  end

  def search_users
  end

  def search_posts
  end

end
