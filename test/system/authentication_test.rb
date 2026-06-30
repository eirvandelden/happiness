require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:user)
  end

  test "user can sign in and view mood form" do
    system_sign_in_as(@user)

    assert_current_path root_path
    assert_text I18n.t("state_of_minds.new.title")
    assert_selector "form[action='#{state_of_minds_path}']"
  end

  test "user can sign out" do
    system_sign_in_as(@user)
    click_button I18n.t("sessions.sign_out")

    assert_current_path root_path
    assert_text I18n.t("sessions.destroy.success")
  end

  test "user cannot access without signing in" do
    visit edit_preferences_path

    assert_current_path new_session_path
  end
end
