require "test_helper"

class ExceptionNotificationTest < ActiveSupport::TestCase
  test "Rack re-raises uncaught application exceptions after notifying Campfire" do
    notification = nil
    middleware = ExceptionNotification::Rack.new(
      ->(_env) { raise RuntimeError, "Campfire test exception" },
      campfire: { webhook_url: "https://example.test/rooms/1/bot/messages" }
    )

    with_stubbed_http_post(->(body) { notification = body }) do
      error = assert_raises(RuntimeError) do
        middleware.call(Rack::MockRequest.env_for("/"))
      end

      assert_equal "Campfire test exception", error.message
    end

    assert_includes notification, "RuntimeError: Campfire test exception"
  ensure
    ExceptionNotifier.unregister_exception_notifier(:campfire)
  end

  test "Rack re-raises application exceptions when Campfire delivery fails" do
    middleware = ExceptionNotification::Rack.new(
      ->(_env) { raise RuntimeError, "Campfire test exception" },
      campfire: { webhook_url: "https://example.test/rooms/1/bot/messages" }
    )

    with_stubbed_http_post(->(_body) { raise SocketError, "Campfire unavailable" }) do
      error = assert_raises(RuntimeError) do
        middleware.call(Rack::MockRequest.env_for("/"))
      end

      assert_equal "Campfire test exception", error.message
    end
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
