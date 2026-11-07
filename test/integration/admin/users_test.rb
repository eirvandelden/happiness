require "test_helper"

class Admin::UsersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:user)
  end

  test "admin can list users" do
    sign_in_as(@admin)
    get admin_users_path

    assert_response :success
    assert_select "td", text: @user.email
  end

  test "the users table stacks on narrow screens" do
    sign_in_as(@admin)
    get admin_users_path

    assert_select "table[data-stack=medium][role=table][aria-labelledby=users-title]"
    assert_select "#users-title", text: I18n.t("admin.users.index.title")
    assert_select "thead[role=rowgroup] tr[role=row] th[role=columnheader]", count: 6
    assert_select "tbody[role=rowgroup] tr[role=row] td[role=cell][data-label]"
    assert_select "td[data-label=?] time[datetime]", I18n.t("admin.users.index.created_at")
  end

  test "the user form puts its buttons in an action row" do
    sign_in_as(@admin)

    [ new_admin_user_path, edit_admin_user_path(@user) ].each do |path|
      get path

      assert_select "form > footer:last-child input[type=submit]"
      assert_select "form > footer:last-child a"
      assert_select "form > nav", count: 0
    end
  end

  test "each deletable user has a delete dialog" do
    sign_in_as(@admin)
    get admin_users_path

    deletable = User.where.not(id: @admin.id)

    assert_select "dialog[id^=delete-user-]", count: deletable.count
    assert_select "dialog#delete-user-#{@admin.id}", count: 0
    assert_select "button[type=button][commandfor=delete-user-#{@user.id}][command=show-modal]"
    assert_select "dialog#delete-user-#{@user.id}[aria-labelledby]" do
      assert_select "footer form[method=dialog] button"
      assert_select "footer form[action=?] input[name=_method][value=delete]", admin_user_path(@user)
    end
    assert_select "[data-turbo-confirm]", count: 0
  end

  test "admin can view a user" do
    sign_in_as(@admin)
    get admin_user_path(@user)

    assert_response :success
    assert_select "dd", text: @user.email
  end

  test "admin can reach new user form" do
    sign_in_as(@admin)
    get new_admin_user_path

    assert_response :success
    assert_select "form"
  end

  test "admin can create a user" do
    sign_in_as(@admin)

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          name: "Created User",
          email: "created@example.com",
          role: "user",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    created_user = User.find_by!(email: "created@example.com")

    assert_redirected_to admin_user_path(created_user)
  end

  test "admin can edit a user" do
    sign_in_as(@admin)
    get edit_admin_user_path(@user)

    assert_response :success
    assert_select "form"
  end

  test "admin can update a user" do
    sign_in_as(@admin)
    patch admin_user_path(@user), params: { user: { name: "Updated Name", role: "admin" } }

    assert_redirected_to admin_user_path(@user)
    assert_equal "Updated Name", @user.reload.name
    assert_equal "admin", @user.role
  end

  test "admin cannot assign an invalid role" do
    sign_in_as(@admin)

    patch admin_user_path(@user), params: { user: { role: "owner" } }

    assert_response :unprocessable_entity
    assert_equal "user", @user.reload.role
  end

  test "admin cannot delete themselves" do
    sign_in_as(@admin)

    assert_no_difference("User.count") do
      delete admin_user_path(@admin)
    end

    assert_redirected_to admin_users_path
  end

  test "non-admin user is redirected for all actions" do
    sign_in_as(@user)

    get admin_users_path

    assert_redirected_to root_path

    get admin_user_path(@admin)

    assert_redirected_to root_path

    get new_admin_user_path

    assert_redirected_to root_path

    post admin_users_path, params: {
      user: {
        name: "Blocked User",
        email: "blocked@example.com",
        role: "user",
        password: "password",
        password_confirmation: "password"
      }
    }

    assert_redirected_to root_path

    get edit_admin_user_path(@admin)

    assert_redirected_to root_path

    patch admin_user_path(@admin), params: { user: { name: "Should Not Work" } }

    assert_redirected_to root_path

    delete admin_user_path(@admin)

    assert_redirected_to root_path
  end
end
