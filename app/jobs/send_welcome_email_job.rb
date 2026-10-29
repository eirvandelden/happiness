class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  #: (User) -> void
  def perform(user)
    UserMailer.welcome(user).deliver_now
  end
end
