require "test_helper"

class FakeFailingJob < ApplicationJob
  def perform
    raise RuntimeError, "Campfire job test exception"
  end
end

class ApplicationJobTest < ActiveSupport::TestCase
  CAMPFIRE_NOTIFICATION_LOCK = Mutex.new

  test "notifies Campfire when a job raises an unhandled exception" do
    notification = with_stubbed_campfire_notification do
      assert_raises(RuntimeError) { FakeFailingJob.perform_now }
    end

    assert_includes notification, "RuntimeError: Campfire job test exception"
  end

  test "names the failing job in the Campfire notification" do
    notification = with_stubbed_campfire_notification do
      assert_raises(RuntimeError) { FakeFailingJob.perform_now }
    end

    summary_line = notification.lines.first
    assert_includes summary_line, "FakeFailingJob"
  end

  test "does not let two threads stub Campfire notifications at the same time" do
    concurrent_stubs = 0
    max_concurrent_stubs = 0
    count_lock = Mutex.new

    threads = 2.times.map do
      Thread.new do
        with_stubbed_campfire_notification do
          count_lock.synchronize { max_concurrent_stubs = [ max_concurrent_stubs, concurrent_stubs += 1 ].max }
          sleep 0.05
          count_lock.synchronize { concurrent_stubs -= 1 }
        end
      end
    end
    threads.each(&:join)

    assert_equal 1, max_concurrent_stubs
  end

  private

  def with_stubbed_campfire_notification
    CAMPFIRE_NOTIFICATION_LOCK.synchronize do
      ExceptionNotifier.register_exception_notifier(:campfire, webhook_url: "https://example.test/rooms/1/bot/messages")
      original_post = Net::HTTP.method(:post)
      notification = nil
      Net::HTTP.define_singleton_method(:post) { |_uri, body, _headers| notification = body }

      yield

      notification
    ensure
      Net::HTTP.define_singleton_method(:post, original_post)
      ExceptionNotifier.unregister_exception_notifier(:campfire)
    end
  end
end
