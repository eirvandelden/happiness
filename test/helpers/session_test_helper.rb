# Test helpers for user authentication in integration and system tests.
module SessionTestHelper
  # Signs in a user via POST request (for integration tests).
  #
  # @param user [User] the user to sign in
  # @return [void]
  # @example
  #   sign_in_as(users(:admin))
  #   get dashboard_path
  #   assert_response :success
  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email,
      password: "password"
    }
  end

  # Signs out the current user via DELETE request (for integration tests).
  #
  # @return [void]
  # @example
  #   sign_out
  #   get dashboard_path
  #   assert_redirected_to new_session_path
  def sign_out
    delete session_path
  end

  # Asserts that a user is currently authenticated.
  #
  # @return [void]
  # @raise [Minitest::Assertion] if no user is authenticated
  # @example
  #   sign_in_as(@user)
  #   assert_authenticated
  def assert_authenticated
    assert_not_nil Current.user, "Expected user to be authenticated"
  end

  # Asserts that no user is currently authenticated.
  #
  # @return [void]
  # @raise [Minitest::Assertion] if a user is authenticated
  # @example
  #   assert_not_authenticated
  #   get dashboard_path
  #   assert_redirected_to new_session_path
  def assert_not_authenticated
    assert_nil Current.user, "Expected user to not be authenticated"
  end

  # Signs in a user via browser UI (for system tests).
  #
  # @param user [User] the user to sign in
  # @return [void]
  # @example
  #   system_sign_in_as(users(:admin))
  #   assert_text "Dashboard"
  def system_sign_in_as(user)
    visit new_session_path
    fill_in I18n.t("appkit.sessions.new.email_placeholder"), with: user.email
    fill_in I18n.t("appkit.sessions.new.password_placeholder"), with: "password"
    click_button I18n.t("appkit.sessions.new.submit")
  end
end
