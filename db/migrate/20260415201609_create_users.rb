class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, default: 0, null: false
      t.string :locale, default: "en", null: false
      t.string :timezone, default: "UTC", null: false
      t.integer :color_scheme, default: 0, null: false
      t.integer :light_theme, default: 1, null: false
      t.integer :dark_theme, default: 1, null: false
      t.string :name



      t.datetime :last_login_at






      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
