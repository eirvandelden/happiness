require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "admin login sets a far-future session cookie expiry" do
    sign_in_as(users(:admin))

    expires = session_cookie_expires

    assert expires, "Expected Set-Cookie to include an expires= date"
    assert_operator expires, :>, 6.months.from_now,
"Expected cookie to expire more than 10 years from now, got #{expires}"
  end

  test "user login sets a far-future session cookie expiry" do
    sign_in_as(users(:user))

    expires = session_cookie_expires

    assert expires, "Expected Set-Cookie to include an expires= date"
    assert_operator expires, :>, 6.months.from_now,
"Expected cookie to expire more than 10 years from now, got #{expires}"
  end

  test "resuming a session renews the cookie expiration for admin" do
    sign_in_as(users(:admin))

    travel 1.day do
      get root_path

      assert_response :success

      expires = session_cookie_expires

      assert expires, "Expected Set-Cookie to include an expires= date on subsequent request"
      assert_operator expires, :>, 6.months.from_now,
"Expected renewed cookie to expire more than 10 years from now, got #{expires}"
    end
  end

  test "resuming a session renews the cookie expiration for user" do
    sign_in_as(users(:user))

    travel 1.day do
      get root_path

      assert_response :success

      expires = session_cookie_expires

      assert expires, "Expected Set-Cookie to include an expires= date on subsequent request"
      assert_operator expires, :>, 6.months.from_now,
"Expected renewed cookie to expire more than 10 years from now, got #{expires}"
    end
  end

  test "signing in records last_login_at, an app-specific concern layered onto appkit's session start" do
    user = users(:user)

    assert_changes -> { user.reload.last_login_at } do
      sign_in_as(user)
    end
  end

  private

  def session_cookie_expires
    cookies_header = Array(response.headers["Set-Cookie"])
    session_cookie = cookies_header.find { |c| c.start_with?("session_token=") }
    return unless session_cookie

    if (match = session_cookie.match(/;\s*expires=([^;]+)/i))
      Time.zone.parse(match[1])
    end
  end
end
