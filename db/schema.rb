# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_18_230850) do
  create_table "appkit_push_subscriptions", force: :cascade do |t|
    t.string "auth_key"
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["endpoint"], name: "index_appkit_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_appkit_push_subscriptions_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_active_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "state_of_minds", force: :cascade do |t|
    t.json "contexts", default: [], null: false
    t.datetime "created_at", null: false
    t.json "emotions", default: [], null: false
    t.string "entry_type", default: "momentary", null: false
    t.integer "mood_score", null: false
    t.text "note"
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["entry_type"], name: "index_state_of_minds_on_entry_type"
    t.index ["user_id"], name: "index_state_of_minds_on_user_id"
    t.check_constraint "entry_type IN ('momentary', 'daily')", name: "check_state_of_minds_entry_type_values"
    t.check_constraint "mood_score BETWEEN 1 AND 5", name: "check_state_of_minds_mood_score_range"
  end

  create_table "users", force: :cascade do |t|
    t.integer "color_scheme", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "dark_theme", default: 1, null: false
    t.string "email", null: false
    t.datetime "last_login_at"
    t.datetime "last_reminded_at"
    t.integer "light_theme", default: 1, null: false
    t.string "locale", default: "nl", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "appkit_push_subscriptions", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "state_of_minds", "users"
end
