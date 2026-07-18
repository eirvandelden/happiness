class ReminderJob < ApplicationJob
  # Local-time windows ported from the former periodicSync service worker: users
  # are nudged once per window per day if they have not yet logged a mood.
  WINDOWS = [ [ 9, 30, 12, 30 ], [ 14, 30, 17, 30 ], [ 19, 30, 22, 30 ] ].freeze

  def perform
    window = current_window
    return unless window

    User.due_for_reminder(window).find_each { |user| remind(user) }
  end

  private

  def current_window
    now = Time.zone.now
    WINDOWS
      .map { |sh, sm, eh, em| now.change(hour: sh, min: sm)..now.change(hour: eh, min: em) }
      .find { |range| range.cover?(now) }
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
