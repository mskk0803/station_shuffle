require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get destinations_new_url
    assert_response :success
  end
end
