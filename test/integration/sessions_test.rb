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

    assert_equal root_path, path
  end

  # Appkit::Authentication#request_authentication does not set a flash message
  # (it only stores return_to_after_authenticating); the login form is enough
  # context for the redirect, matching the engine's canonical behavior.
  test "unauthenticated user visiting protected route is redirected to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "invalid credentials do not sign in user" do
    post session_path, params: {
      email_address: @user.email,
      password: "wrong-password"
    }

    assert_response :unauthorized
    assert_match I18n.t("appkit.sessions.rejection"), response.body
    get root_path
    assert_redirected_to new_session_path
  end
end
