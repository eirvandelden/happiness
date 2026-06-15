class CreateStateOfMinds < ActiveRecord::Migration[8.1]
  def change
    create_table :state_of_minds do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :mood_score, null: false
      t.string :entry_type, null: false, default: "momentary"
      t.json :emotions, null: false, default: []
      t.json :contexts, null: false, default: []
      t.text :note
      t.datetime :recorded_at, null: false

      t.timestamps
    end
    add_index :state_of_minds, :entry_type
    add_check_constraint :state_of_minds, "mood_score BETWEEN 1 AND 5", name: "check_state_of_minds_mood_score_range"
    add_check_constraint :state_of_minds, "entry_type IN ('momentary', 'daily')",
                         name: "check_state_of_minds_entry_type_values"
  end
end
