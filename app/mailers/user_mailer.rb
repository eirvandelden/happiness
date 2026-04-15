class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to #{Rails.application.class.module_parent_name}!")
  end

  def password_reset(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Password Reset Instructions")
  end
end
