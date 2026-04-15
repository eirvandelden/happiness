module Authorization
  extend ActiveSupport::Concern

  private

  def ensure_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: "You must be an admin to access this page"
    end
  end
end
