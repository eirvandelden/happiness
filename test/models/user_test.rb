require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "available locales match app locales" do
    assert_equal %w[en nl it], User::AVAILABLE_LOCALES
  end

  test "new users default to dutch locale" do
    assert_equal "nl", User.new.locale
  end
end
