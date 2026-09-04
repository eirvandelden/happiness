class StateOfMind < ApplicationRecord
  belongs_to :user

  EMOTIONS = %w[happy hopeful grateful excited content calm angry frustrated sad anxious drained disgusted
indifferent].freeze
  CONTEXTS = %w[work relationships family health sleep exercise current_events weather other].freeze
  ENTRY_TYPES = %w[momentary daily].freeze

  enum :entry_type, { momentary: "momentary", daily: "daily" }, default: :momentary, validate: true

  validates :mood_score, presence: true, inclusion: { in: 1..5 }
  validates :entry_type, presence: true
  validates :recorded_at, presence: true
  validate :emotions_are_known
  validate :contexts_are_known

  before_validation :normalize_collections
  before_validation :set_recorded_at

  private

  def emotions_are_known
    errors.add(:emotions, :inclusion) unless known_values?(emotions, EMOTIONS)
  end

  def known_values?(values, allowed_values)
    values.is_a?(Array) && (values - allowed_values).empty?
  end

  def contexts_are_known
    errors.add(:contexts, :inclusion) unless known_values?(contexts, CONTEXTS)
  end

  def normalize_collections
    self.emotions = normalize_collection(emotions)
    self.contexts = normalize_collection(contexts)
  end

  def normalize_collection(value)
    return value unless value.is_a?(String)

    JSON.parse(value)
  rescue JSON::ParserError
    value
  end

  def set_recorded_at
    self.recorded_at ||= Time.current
  end
end
