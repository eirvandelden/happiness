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
    assert_match I18n.t("sessions.destroy.success"), response.body
  end

  test "unauthenticated user visiting protected route is redirected with flash" do
    get root_path

    assert_redirected_to new_session_path
    follow_redirect!

    assert_match I18n.t("authentication.please_sign_in"), response.body
  end

  test "invalid credentials do not sign in user" do
    post session_path, params: {
      email: @user.email,
      password: "wrong-password"
    }

    assert_response :unprocessable_entity
    assert_match I18n.t("sessions.create.failure"), response.body
    get root_path
    assert_redirected_to new_session_path
  end
end
