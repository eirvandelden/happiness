require "test_helper"

class Admin::DashboardTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:user)
  end

  test "non-admin user is redirected away" do
    sign_in_as(@user)
    get admin_root_path

    assert_redirected_to root_path
  end

  test "admin can access dashboard and sees user table" do
    sign_in_as(@admin)
    get admin_root_path

    assert_response :success
    assert_select "table"
    assert_select "td", text: @admin.email
  end

  test "the recent logins table stacks on narrow screens" do
    sign_in_as(@admin)
    get admin_root_path

    assert_select "table[data-stack=medium][role=table][aria-labelledby=recent-logins]"
    assert_select "#recent-logins", text: I18n.t("admin.dashboard.index.recent_logins")
    assert_select "thead[role=rowgroup] tr[role=row] th[role=columnheader]", count: 5
    assert_select "tbody[role=rowgroup] tr[role=row] td[role=cell][data-label]"
    assert_select "td[data-label=?] time[datetime]", I18n.t("admin.dashboard.index.last_login_at")
  end

  test "dashboard shows user counts" do
    sign_in_as(@admin)
    get admin_root_path

    assert_response :success
    assert_select "dd", text: User.count.to_s
    assert_select "dd", text: User.admin.count.to_s
  end
end
