require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # Devise のテストヘルパー

  # ログインする
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test "should get index" do
    get posts_path
    assert_response :success
  end

  test "should get new" do
    get new_post_path
    assert_response :success
  end

  test "should create post" do
    user = users(:user_one)
    post = Post.create(user: user, content: "Hello, world!")
    assert post.valid?
  end

  # test "should get destroy" do
  #   get posts_destroy_url
  #   assert_response :success
  # end
end
