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
end
