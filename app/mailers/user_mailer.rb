class UserMailer < ApplicationMailer
  #: (User) -> Mail::Message
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to #{Rails.application.class.module_parent_name}!")
  end
end
