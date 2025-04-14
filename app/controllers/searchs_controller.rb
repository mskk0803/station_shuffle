class SearchsController < ApplicationController
  def index
    @q_users = User.ransack(params[:q])
    @users = @q_users.result(distinct: true)

    @q_posts = Post.ransack(params[:q])
    @posts = @q_posts.result(distinct: true)
  end
end
