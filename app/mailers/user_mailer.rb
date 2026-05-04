class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to #{Rails.application.class.module_parent_name}!")
  end
end
