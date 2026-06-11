class StateOfMind < ApplicationRecord
  belongs_to :user

  EMOTIONS = %w[happy hopeful grateful excited content calm angry sad anxious drained disgusted indifferent].freeze
  CONTEXTS = %w[work relationships health sleep exercise current_events weather other].freeze
  ENTRY_TYPES = %w[momentary daily].freeze

  enum :entry_type, { momentary: "momentary", daily: "daily" }, default: :momentary, validate: true

  validates :mood_score, presence: true, inclusion: { in: 1..5 }
  validates :entry_type, presence: true
  validates :recorded_at, presence: true
  validate :emotions_are_known
  validate :contexts_are_known

  before_validation :set_recorded_at

  private

  def set_recorded_at
    self.recorded_at ||= Time.current
  end

  def emotions_are_known
    errors.add(:emotions, :inclusion) unless known_values?(emotions, EMOTIONS)
  end

  def contexts_are_known
    errors.add(:contexts, :inclusion) unless known_values?(contexts, CONTEXTS)
  end

  def known_values?(values, allowed_values)
    (Array(values) - allowed_values).empty?
  end
end
