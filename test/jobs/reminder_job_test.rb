require "test_helper"

class ReminderJobTest < ActiveJob::TestCase
  setup do
    @user = users(:user)
    @user.push_subscriptions.create!(endpoint: "https://push.example/#{SecureRandom.hex}", p256dh_key: "k", auth_key: "a")
  end

  test "fires a push for a subscribed user with no entry in the current window" do
    travel_to time_at(11, 0) do
      assert_enqueued_with(job: Appkit::PushNotificationJob) do
        ReminderJob.perform_now
      end
    end
  end

  test "enqueues one push per subscription" do
    @user.push_subscriptions.create!(endpoint: "https://push.example/#{SecureRandom.hex}", p256dh_key: "k", auth_key: "a")

    travel_to time_at(16, 0) do
      assert_enqueued_jobs 2, only: Appkit::PushNotificationJob do
        ReminderJob.perform_now
      end
    end
  end

  test "does not fire when the user already recorded an entry in the current window" do
    travel_to time_at(11, 0) do
      @user.state_of_minds.create!(mood_score: 3, recorded_at: time_at(10, 0))

      assert_no_enqueued_jobs only: Appkit::PushNotificationJob do
        ReminderJob.perform_now
      end
    end
  end

  test "does not fire outside every reminder window" do
    travel_to time_at(13, 0) do
      assert_no_enqueued_jobs only: Appkit::PushNotificationJob do
        ReminderJob.perform_now
      end
    end
  end

  test "does not fire for users without a push subscription" do
    @user.push_subscriptions.destroy_all

    travel_to time_at(21, 0) do
      assert_no_enqueued_jobs only: Appkit::PushNotificationJob do
        ReminderJob.perform_now
      end
    end
  end

  private

  def time_at(hour, minute)
    Time.zone.now.change(hour: hour, min: minute)
  end
end
