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
end
