require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:user)
    system_sign_in_as(users(:admin))
    visit admin_users_path
  end

  test "admin deletes a user through the confirmation dialog" do
    within(user_row) { click_button I18n.t("admin.users.index.delete_trigger") }
    within("dialog#delete-user-#{@user.id}") { click_button I18n.t("admin.users.index.delete") }

    assert_text I18n.t("admin.users.destroy.success")
    assert_no_selector "td", exact_text: @user.email
  end

  test "cancelling the dialog keeps the user" do
    within(user_row) { click_button I18n.t("admin.users.index.delete_trigger") }
    within("dialog#delete-user-#{@user.id}") { click_button I18n.t("admin.users.index.cancel") }

    assert_no_selector "dialog[open]"
    assert_selector "td", exact_text: @user.email
    assert User.exists?(@user.id)
  end

  private

  def user_row
    find("td", exact_text: @user.email).ancestor("tr")
  end
end
