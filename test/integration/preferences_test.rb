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
    patch preferences_path, params: { user: { color_scheme: "light", light_theme: "white" } }

    assert_redirected_to edit_preferences_path
    follow_redirect!

    assert_select "aside[role=status]"
  end

  test "settings page shows the reminders control" do
    get edit_preferences_path

    assert_select "fieldset[data-controller=notifications]" do
      assert_select "button[type=button]", text: I18n.t("notifications.enable_reminders")
      assert_select "small[role=status][data-notifications-target=status]"
    end
  end

  test "reminders control is not rendered in the global layout" do
    get root_path

    assert_select "[data-controller=notifications]", count: 0
  end
end
