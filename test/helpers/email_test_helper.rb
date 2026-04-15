module EmailTestHelper
  def assert_email_sent(to:, subject: nil)
    email = ActionMailer::Base.deliveries.last
    assert email, "No email was sent"
    assert_equal to, email.to.first
    assert_match subject, email.subject if subject
  end

  def assert_email_body_includes(text)
    email = ActionMailer::Base.deliveries.last
    assert email, "No email was sent"
    assert_includes email.body.to_s, text
  end

  def clear_emails
    ActionMailer::Base.deliveries.clear
  end
end
