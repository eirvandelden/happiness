module ChartsHelper
  # @api private
  MOOD_CHART_DIMS = {
    width: 640, height: 320,
    pad_left: 50, pad_top: 20, pad_right: 20, pad_bottom: 40
  }.freeze

  # @api private
  EMOTION_CHART_DIMS = {
    width: 640,
    pad_top: 20, pad_bottom: 20, pad_right: 20,
    row_height: 28, label_width: 110
  }.freeze

  # Renders an inline SVG line chart of mood scores over time.
  #
  # @param entries [Array<StateOfMind>] records to plot by recorded_at
  # @return [String] HTML-safe SVG markup, or an empty paragraph when no entries
  def svg_mood_chart(entries)
    data = Array(entries).sort_by(&:recorded_at).last(30)
    return content_tag(:p, "") if data.empty?

    d         = MOOD_CHART_DIMS
    chart_w   = d[:width]  - d[:pad_left] - d[:pad_right]
    chart_h   = d[:height] - d[:pad_top]  - d[:pad_bottom]
    n         = data.size

    content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 #{d[:width]} #{d[:height]}",
                role: "img") do
      parts = mood_grid_lines(d, chart_h)
      parts += mood_points(data, n, d, chart_w, chart_h)
      safe_join(parts)
    end
  end

  # Renders an inline SVG horizontal bar chart of emotion frequencies.
  #
  # @param entries [Array<StateOfMind>] records
  # @return [String] HTML-safe SVG markup, or an empty paragraph when no emotions
  def svg_emotion_chart(entries)
    counts = emotion_counts(Array(entries))
    return content_tag(:p, "") if counts.empty?

    d          = EMOTION_CHART_DIMS
    max_count  = counts.first[1].to_f
    bar_area   = d[:width] - d[:label_width] - d[:pad_right]
    height     = d[:pad_top] + counts.size * d[:row_height] + d[:pad_bottom]

    content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 #{d[:width]} #{height}",
                role: "img") do
      parts = counts.each_with_index.map do |(emotion, count), i|
        emotion_bar_row(emotion, count, i, max_count, bar_area, d)
      end
      safe_join(parts)
    end
  end

  private

  def mood_grid_lines(d, chart_h)
    (1..5).map do |score|
      y = d[:pad_top] + chart_h - ((score - 1).to_f / 4 * chart_h).round
      tag.line(x1: d[:pad_left], y1: y, x2: d[:width] - d[:pad_right], y2: y,
               stroke: "var(--color-border, #ccc)", "stroke-width": "1") +
        tag.text(score.to_s, x: d[:pad_left] - 4, y: y + 4,
                 "text-anchor": "end", "font-size": "10", fill: "currentColor")
    end
  end

  def mood_points(data, n, d, chart_w, chart_h)
    points = data.each_with_index.map do |entry, i|
      x = if n == 1
            d[:pad_left] + chart_w / 2
      else
            (d[:pad_left] + (i.to_f / (n - 1)) * chart_w).round
      end
      y = (d[:pad_top] + chart_h - ((entry.mood_score - 1).to_f / 4 * chart_h)).round
      [ x, y ]
    end

    polyline_pts = points.map { |x, y| "#{x},#{y}" }.join(" ")
    circles = points.map { |x, y| tag.circle(cx: x, cy: y, r: 3, fill: "var(--color-accent, #666)") }

    [
      tag.polyline(points: polyline_pts, fill: "none",
                   stroke: "var(--color-accent, #666)", "stroke-width": "2")
    ] + circles
  end

  def emotion_counts(entries)
    tally = Hash.new(0)
    entries.each do |entry|
      emotions = entry.emotions
      emotions = Array(emotions.is_a?(String) ? JSON.parse(emotions) : emotions)
      emotions.each { |e| tally[e] += 1 }
    end
    tally.select { |_, c| c > 0 }.sort_by { |_, c| -c }
  end

  def emotion_bar_row(emotion, count, index, max_count, bar_area, d)
    bar_w = (count.to_f / max_count * bar_area).round
    y     = d[:pad_top] + index * d[:row_height]

    label_el = tag.text(t("state_of_minds.emotions.#{emotion}"),
                        x: d[:label_width] - 4,
                        y: y + d[:row_height] / 2 + 4,
                        "text-anchor": "end",
                        "font-size": "11",
                        fill: "currentColor")
    bar_el   = tag.rect(x: d[:label_width], y: y + 4,
                        width: bar_w, height: d[:row_height] - 8,
                        fill: "var(--color-accent, #666)", rx: 2)

    safe_join([ label_el, bar_el ])
  end
end
