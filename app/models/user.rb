class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Available locales
  AVAILABLE_LOCALES = %w[en nl it].freeze

  # Enums
  enum :role, { user: 0, admin: 1 }, default: :user
  enum :color_scheme, { system: 0, light: 1, dark: 2 }, default: :system
  enum :light_theme, { white: 0, selenized_light: 1 }, default: :selenized_light
  enum :dark_theme, { black: 0, selenized_dark: 1 }, default: :selenized_dark

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

  # Set default locale
  after_initialize :set_defaults, if: :new_record?

  # Return timezone as ActiveSupport::TimeZone object
  def time_zone
    ActiveSupport::TimeZone[timezone]
  end

  private

  def set_defaults
    self.locale ||= "nl"
    self.timezone ||= "UTC"
  end
end
