require "test_helper"

class StateOfMindTest < ActiveSupport::TestCase
  test "new entries default collections to arrays" do
    state_of_mind = StateOfMind.new

    assert_equal [], state_of_mind.emotions
    assert_equal [], state_of_mind.contexts
  end

  test "json string collection defaults are treated as empty arrays" do
    state_of_mind = StateOfMind.new(user: users(:user), mood_score: 3, emotions: "[]", contexts: "[]")

    assert_predicate state_of_mind, :valid?
    assert_equal [], state_of_mind.emotions
    assert_equal [], state_of_mind.contexts
  end

  test "emotions must be known" do
    state_of_mind = StateOfMind.new(user: users(:user), mood_score: 3, emotions: [ "unknown" ])

    assert_not state_of_mind.valid?
    assert state_of_mind.errors.of_kind?(:emotions, :inclusion)
  end

  test "contexts must be known" do
    state_of_mind = StateOfMind.new(user: users(:user), mood_score: 3, contexts: [ "unknown" ])

    assert_not state_of_mind.valid?
    assert state_of_mind.errors.of_kind?(:contexts, :inclusion)
  end

  test "database enforces mood score range" do
    assert_raises(ActiveRecord::StatementInvalid) do
      StateOfMind.insert!(state_of_mind_attributes(mood_score: 99))
    end
  end

  test "database enforces entry type values" do
    assert_raises(ActiveRecord::StatementInvalid) do
      StateOfMind.insert!(state_of_mind_attributes(entry_type: "weekly"))
    end
  end

  private

  def state_of_mind_attributes(overrides = {})
    {
      user_id: users(:user).id,
      mood_score: 3,
      entry_type: "momentary",
      emotions: [],
      contexts: [],
      recorded_at: Time.current,
      created_at: Time.current,
      updated_at: Time.current
    }.merge(overrides)
  end
end
