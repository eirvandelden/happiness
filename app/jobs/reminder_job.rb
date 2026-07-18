class ReminderJob < ApplicationJob
  # Local-time windows ported from the former periodicSync service worker: users
  # are nudged once per window per day if they have not yet logged a mood, evaluated
  # in each user's own timezone rather than the server's.
  WINDOWS = [ [ 9, 30, 12, 30 ], [ 14, 30, 17, 30 ], [ 19, 30, 22, 30 ] ].freeze

  def perform
    User.joins(:push_subscriptions).distinct.find_each { |user| remind_if_due(user) }
  end

  private

  def remind_if_due(user)
    window = user.current_reminder_window(WINDOWS)
    return unless window
    return if user.recorded_within?(window)

    remind(user)
  end

  def remind(user)
    payload = reminder_payload(user.locale)
    user.push_subscriptions.each { |subscription| Appkit::PushNotificationJob.perform_later(subscription, payload) }
  end

  def reminder_payload(locale)
    {
      title: I18n.t("notifications.reminder_title", locale: locale),
      body: I18n.t("notifications.reminder_body", locale: locale),
      icon: "/icon-192.png",
      tag: "happiness-reminder",
      data: { path: "/" }
    }
  end
end
