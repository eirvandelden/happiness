require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "available locales match app locales" do
    assert_equal %w[en nl it], User::AVAILABLE_LOCALES
  end

  test "new users default to dutch locale" do
    assert_equal "nl", User.new.locale
  end

  test "appkit first_run creates an admin, matching Happiness's role enum (not the engine's :administrator)" do
    user = Appkit::FirstRun.create!(email: "first-admin-#{SecureRandom.hex(4)}@example.com", password: "password")

    assert user.admin?
  end
end
