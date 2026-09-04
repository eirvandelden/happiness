class User < ApplicationRecord
  include Appkit::Authenticatable
  include Appkit::UserTheming

  has_many :state_of_minds, dependent: :destroy

  # Available locales
  AVAILABLE_LOCALES = %w[en nl it].freeze

  # Enums
  enum :role, { user: 0, admin: 1 }, default: :user

  # Validations
  validates :name, presence: false
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
  validates :locale, presence: true, inclusion: { in: AVAILABLE_LOCALES }
  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
  validates :color_scheme, presence: true
  validates :light_theme, presence: true
  validates :dark_theme, presence: true

  # Normalizations
  normalizes :name, with: ->(name) { name&.strip }
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Callbacks
  after_create_commit -> { SendWelcomeEmailJob.perform_later(self) }

  after_initialize :set_defaults

  # Return timezone as ActiveSupport::TimeZone object
  def time_zone
    ActiveSupport::TimeZone[timezone]
  end

  # The reminder window (out of the given windows) that covers this user's current
  # local time, or nil if their local time is outside every window right now.
  def current_reminder_window(windows)
    now = time_zone.now
    windows
      .map { |sh, sm, eh, em| now.change(hour: sh, min: sm)..now.change(hour: eh, min: em) }
      .find { |range| range.cover?(now) }
  end

  # Whether this user already recorded an entry within the given (timezone-aware) window.
  def recorded_within?(window)
    state_of_minds.where(recorded_at: window).exists?
  end

  # Whether a reminder was already sent within the given (timezone-aware) window —
  # needed because the recurring job runs frequently, not once per window.
  def reminded_within?(window)
    last_reminded_at.present? && window.cover?(last_reminded_at)
  end

  private

  def set_defaults
    return unless new_record?

    self.locale ||= "nl"
    self.timezone ||= "UTC"
  end
end
