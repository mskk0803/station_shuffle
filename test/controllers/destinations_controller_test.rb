require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_destination_path
    assert_response :success
  end
end
