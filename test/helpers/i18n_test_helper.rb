module I18nTestHelper
  # Test that all translations are present for a given locale
  def assert_translations_present(locale, keys)
    I18n.with_locale(locale) do
      keys.each do |key|
        translation = I18n.t(key, raise: true)
        assert translation.present?, "Missing translation for #{locale}.#{key}"
      rescue I18n::MissingTranslationData
        flunk "Missing translation for #{locale}.#{key}"
      end
    end
  end

  # Test that no translations are missing across all locales
  def assert_no_missing_translations
    require "i18n/tasks"
    i18n = I18n::Tasks::BaseTask.new
    missing = i18n.missing_keys

    assert missing.empty?, "Missing translations:\n#{missing.inspect}"
  end

  # Test that no translations are unused
  def assert_no_unused_translations
    require "i18n/tasks"
    i18n = I18n::Tasks::BaseTask.new
    unused = i18n.unused_keys

    assert unused.empty?, "Unused translations:\n#{unused.inspect}"
  end
end
