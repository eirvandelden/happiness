require "test_helper"

class EagerLoadingTest < ActiveSupport::TestCase
  test "test environment eager loads without namespace errors" do
    assert_nothing_raised do
      Rails.application.eager_load!
    end
  end
end
