# Restores the sign-in/sign-out flash messages that Happiness's original
# SessionsController showed, which Appkit::SessionsController does not set.
class SessionsController < Appkit::SessionsController
  def create
    super
    flash[:notice] = t(".success") if response.redirect?
  end

  def destroy
    super
    flash[:notice] = t(".success")
  end
end
