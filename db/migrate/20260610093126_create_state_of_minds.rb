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
  end
end
