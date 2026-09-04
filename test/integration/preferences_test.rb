require "test_helper"

class PreferencesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    sign_in_as(@user)
    follow_redirect!
  end

  test "user can update locale" do
    patch preferences_path, params: { user: { locale: "en" } }

    assert_redirected_to edit_preferences_path
    follow_redirect!

    assert_select "aside[role=status]"
  end

  test "user can update timezone" do
    patch preferences_path, params: { user: { timezone: "UTC" } }

    assert_redirected_to edit_preferences_path
    follow_redirect!

    assert_select "aside[role=status]"
  end

  test "user can update theme settings" do
    patch preferences_path, params: { user: { color_scheme: "light", light_theme: "solunized-white" } }

    assert_redirected_to edit_preferences_path
    follow_redirect!

    assert_select "aside[role=status]"
  end

  test "settings page shows the reminders control" do
    get edit_preferences_path

    assert_select "fieldset[data-controller=push]" do
      assert_select "button[type=button]", text: I18n.t("notifications.enable_reminders")
    end
  end

  test "settings page hides the reminders control inside the app" do
    get edit_preferences_path, headers: { "HTTP_USER_AGENT" => ANDROID_APP_USER_AGENT }

    assert_response :success
    assert_select "[data-controller=push]", count: 0
  end

  test "reminders control is not rendered in the global layout" do
    get root_path

    assert_select "[data-controller=push]", count: 0
  end

  private
    # What Hotwire Native Android puts in front of the web view's own user agent.
    ANDROID_APP_USER_AGENT = "Hotwire Native Android; Turbo Native Android; " \
      "Mozilla/5.0 (Linux; Android 16; wv) Chrome/140.0.7339.207 Mobile Safari/537.36"
end
