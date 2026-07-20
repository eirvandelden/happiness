require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "a token is generated automatically via Appkit::SessionBehavior's has_secure_token" do
    session = Session.create!(user: users(:user))

    assert session.token.present?
  end

  test "tokens are unique, replacing the app's former SecureRandom.base58 callback" do
    first = Session.create!(user: users(:user))
    second = Session.create!(user: users(:admin))

    assert_not_equal first.token, second.token
  end
end
