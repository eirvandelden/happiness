require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "service worker uses authenticated user locale" do
    sign_in_as(english_user)

    get pwa_service_worker_path(format: :js)

    assert_response :success
    assert_includes response.body, "showNotification('Happiness'"
    assert_includes response.body, "body: 'How are you feeling? Log your happiness.'"
  end

  test "pwa files are available without authentication" do
    get pwa_manifest_path(format: :json)

    assert_response :success

    get pwa_service_worker_path(format: :js)

    assert_response :success
  end

  test "service worker escapes translated notification strings for javascript" do
    sign_in_as(english_user)

    with_notifications(title: "Happiness's check-in", body: "Line one\nLine two", locale: :en) do
      get pwa_service_worker_path(format: :js)

      assert_response :success
      assert_includes response.body, "showNotification('Happiness\\'s check-in'"
      assert_includes response.body, "body: 'Line one\\nLine two'"
    end
  end

  private

  def english_user
    User.create!(
      email: "english-#{SecureRandom.hex(8)}@example.com",
      password: "password",
      locale: "en",
      timezone: "UTC"
    )
  end

  def with_notifications(title:, body:, locale:)
    I18n.backend.store_translations(locale, notifications: { reminder_title: title, reminder_body: body })
    yield
  ensure
    I18n.reload!
  end
end
