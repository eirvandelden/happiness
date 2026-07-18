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

  # Set default locale
  after_initialize :set_defaults, if: :new_record?

  # Subscribed users who have not yet recorded an entry within the given time window.
  def self.due_for_reminder(window)
    joins(:push_subscriptions).distinct.where.not(id: recorded_within(window))
  end

  def self.recorded_within(window)
    StateOfMind.where(recorded_at: window).select(:user_id)
  end

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
