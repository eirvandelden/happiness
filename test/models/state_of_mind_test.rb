require "test_helper"

class StateOfMindTest < ActiveSupport::TestCase
  test "new entries default collections to arrays" do
    state_of_mind = StateOfMind.new

    assert_equal [], state_of_mind.emotions
    assert_equal [], state_of_mind.contexts
  end
end
