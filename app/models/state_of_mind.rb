class StateOfMind < ApplicationRecord
  belongs_to :user

  EMOTIONS = %w[happy hopeful grateful excited content calm angry sad anxious drained disgusted indifferent].freeze
  CONTEXTS = %w[work relationships health sleep exercise current_events weather other].freeze
  ENTRY_TYPES = %w[momentary daily].freeze

  enum :entry_type, { momentary: "momentary", daily: "daily" }, default: :momentary

  validates :mood_score, presence: true, inclusion: { in: 1..5 }
  validates :entry_type, presence: true
  validates :recorded_at, presence: true

  before_validation :set_recorded_at

  private

  def set_recorded_at
    self.recorded_at ||= Time.current
  end
end
