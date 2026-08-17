require "test_helper"

class ApplicationJobTest < ActiveSupport::TestCase
  test "notifies Campfire when a job raises an unhandled exception" do
    job_class = Class.new(ApplicationJob) do
      def perform
        raise RuntimeError, "Campfire job test exception"
      end
    end

    ExceptionNotifier.register_exception_notifier(:campfire, webhook_url: "https://example.test/rooms/1/bot/messages")

    notification = nil
    with_stubbed_http_post(->(body) { notification = body }) do
      assert_raises(RuntimeError) { job_class.perform_now }
    end

    assert_includes notification, "RuntimeError: Campfire job test exception"
  ensure
    ExceptionNotifier.unregister_exception_notifier(:campfire)
  end

  private

  def with_stubbed_http_post(handler)
    original_post = Net::HTTP.method(:post)
    Net::HTTP.define_singleton_method(:post) { |_uri, body, _headers| handler.call(body) }

    yield
  ensure
    Net::HTTP.define_singleton_method(:post, original_post)
  end
end
