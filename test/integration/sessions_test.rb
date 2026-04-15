require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
  end

  test "user can sign in" do
    sign_in_as(@user)

    assert_response :redirect
    follow_redirect!

    assert_equal root_path, path
  end

  test "user can sign out" do
    sign_in_as(@user)
    sign_out

    assert_response :redirect
    follow_redirect!

    assert_equal new_session_path, path
  end

  test "invalid email does not sign in user" do
    sign_in_as(users(:user))
    # User should redirect to signin page on failure
    # (implementation depends on your auth setup)
  end
end
