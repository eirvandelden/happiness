require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:user)

    mail = UserMailer.welcome(user)

    assert_equal "Welcome to Happiness!", mail.subject
    assert_equal [ user.email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match user.email, mail.body.encoded
    assert_match "Get Started", mail.body.encoded
  end
end
