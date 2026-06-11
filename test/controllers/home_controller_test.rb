require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user sees welcome page" do
    sign_in_as(users(:user))
    follow_redirect!

    assert_response :success
    assert_select "h1"
  end

  test "admin user sees admin panel link" do
    sign_in_as(users(:admin))
    follow_redirect!

    assert_response :success
    assert_select "a[href='#{admin_root_path}']"
  end
end
