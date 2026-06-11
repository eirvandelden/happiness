require "test_helper"

class ChartsHelperTest < ActionView::TestCase
  test "mood chart keeps latest entries" do
    entries = (0..30).map do |days_ago|
      StateOfMind.new(mood_score: days_ago.zero? ? 5 : 1, recorded_at: days_ago.days.ago)
    end

    svg = svg_mood_chart(entries.sort_by(&:recorded_at).reverse)

    assert_match(/<circle[^>]+cy="20"/, svg)
  end

  test "mood chart plots newest entry on the right" do
    entries = [
      StateOfMind.new(mood_score: 5, recorded_at: Time.current),
      StateOfMind.new(mood_score: 3, recorded_at: 1.day.ago),
      StateOfMind.new(mood_score: 1, recorded_at: 2.days.ago)
    ]

    svg = svg_mood_chart(entries)

    assert_match(/<circle[^>]+cx="620"[^>]+cy="20"/, svg)
  end

  test "emotion chart translates labels" do
    state_of_mind = StateOfMind.new(emotions: [ "happy" ])

    I18n.with_locale(:nl) do
      svg = svg_emotion_chart([ state_of_mind ])

      assert_includes svg, I18n.t("state_of_minds.emotions.happy")
      assert_no_match(/>happy</, svg)
    end
  end
end
