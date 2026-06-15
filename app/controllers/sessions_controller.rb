class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: t(".success")
    else
      flash.now[:alert] = t(".failure")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: t(".success")
  end
end
