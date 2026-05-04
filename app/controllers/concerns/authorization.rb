module Authorization
  extend ActiveSupport::Concern

  private

  def ensure_admin
    return if Current.user&.admin?

    redirect_to root_path, alert: t("admin.authorization.require_admin")
  end
end
