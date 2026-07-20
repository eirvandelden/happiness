class ApplicationController < ActionController::Base
  include GearedPagination::Controller
  include Appkit::Authentication
  include Authorization

  before_action :set_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def set_locale
      I18n.locale = Current.user&.locale || I18n.default_locale
      Time.zone = Current.user&.time_zone || Time.zone
    end

    def start_new_session_for(user)
      super.tap { user.update_column(:last_login_at, Time.current) }
    end
end
