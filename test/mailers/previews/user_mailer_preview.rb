# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    UserMailer.welcome(preview_user)
  end

  private

  def preview_user
    User.new(email: "preview@example.com", role: :user)
  end
end
