require "test_helper"

# Chrome's DevTools protocol sometimes reports a detached DOM node (e.g. right after a
# full-page navigation) as a generic UnknownError instead of StaleElementReferenceError.
# Capybara only retries element checks on the latter, so the former escapes as a flaky
# test failure. Teach it to retry on this one too.
Capybara::Selenium::Driver.prepend(Module.new do
  def invalid_element_errors
    super + [ Selenium::WebDriver::Error::UnknownError ]
  end
end)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
