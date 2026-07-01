require "test_helper"
require "helpers/i18n_test_helper"

class I18nTest < ActionDispatch::IntegrationTest
  include I18nTestHelper

  test "app exposes only supported locales" do
    assert_equal %i[en nl it], I18n.available_locales
  end

  test "app default locale is dutch" do
    assert_equal :nl, I18n.default_locale
  end

  test "all locales have required navigation keys" do
    nav_keys = %w[nav.home nav.preferences nav.admin]

    I18n.available_locales.each do |locale|
      assert_translations_present(locale, nav_keys)
    end
  end

  test "all locales have required session keys" do
    session_keys = %w[
      sessions.sign_in
      sessions.sign_out
      sessions.new.title
      sessions.new.email
      sessions.new.password
      sessions.new.submit
    ]

    I18n.available_locales.each do |locale|
      assert_translations_present(locale, session_keys)
    end
  end

  test "locale can be changed" do
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        assert_equal locale, I18n.locale
        assert I18n.t("nav.home").present?
      end
    end
  end

  test "notification landmark label uses current locale in application layout" do
    sign_in_as(users(:user))
    follow_redirect!

    assert_select "section[aria-label=?]", I18n.t("notifications.label")
  end

  test "notification landmark label uses current locale in admin layout" do
    sign_in_as(users(:admin))
    get admin_root_path

    assert_select "section[aria-label=?]", I18n.t("notifications.label")
  end
end
