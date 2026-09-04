class DropFaultlineTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :faultline_error_contexts
    drop_table :faultline_error_occurrences
    drop_table :faultline_request_profiles
    drop_table :faultline_request_traces
    drop_table :faultline_error_groups
  end

  def down
    create_table :faultline_error_groups do |t|
      t.datetime :created_at, null: false
      t.string :exception_class, null: false
      t.string :file_path
      t.string :fingerprint, null: false
      t.datetime :first_seen_at
      t.datetime :last_notified_at
      t.datetime :last_seen_at
      t.integer :line_number
      t.string :method_name
      t.integer :occurrences_count, default: 0
      t.datetime :resolved_at
      t.text :sanitized_message, null: false
      t.string :status, default: "unresolved"
      t.datetime :updated_at, null: false
      t.index :exception_class
      t.index :fingerprint, unique: true
      t.index :last_seen_at
      t.index :status
    end

    create_table :faultline_error_occurrences do |t|
      t.text :backtrace
      t.datetime :created_at, null: false
      t.string :environment
      t.integer :error_group_id, null: false
      t.string :exception_class, null: false
      t.string :hostname
      t.string :ip_address
      t.json :local_variables
      t.text :message, null: false
      t.string :process_id
      t.text :request_headers
      t.string :request_method
      t.text :request_params
      t.string :request_url
      t.string :session_id
      t.datetime :updated_at, null: false
      t.string :user_agent
      t.bigint :user_id
      t.string :user_type
      t.index :created_at
      t.index [ :error_group_id, :created_at ]
      t.index :error_group_id
      t.index [ :user_type, :user_id ]
    end

    create_table :faultline_error_contexts do |t|
      t.datetime :created_at, null: false
      t.integer :error_occurrence_id, null: false
      t.string :key, null: false
      t.datetime :updated_at, null: false
      t.text :value
      t.index [ :error_occurrence_id, :key ]
      t.index :error_occurrence_id
    end

    create_table :faultline_request_traces do |t|
      t.datetime :created_at, null: false
      t.integer :db_query_count, default: 0
      t.float :db_runtime_ms
      t.float :duration_ms
      t.string :endpoint, null: false
      t.boolean :has_profile, default: false
      t.string :http_method, null: false
      t.string :path
      t.json :spans
      t.integer :status
      t.float :view_runtime_ms
      t.index :created_at
      t.index [ :endpoint, :created_at ]
      t.index :endpoint
    end

    create_table :faultline_request_profiles do |t|
      t.datetime :created_at, null: false
      t.float :interval_ms
      t.string :mode, default: "cpu"
      t.text :profile_data, null: false
      t.integer :request_trace_id, null: false
      t.integer :samples, default: 0
      t.index :request_trace_id
    end

    add_foreign_key :faultline_error_contexts, :faultline_error_occurrences, column: :error_occurrence_id
    add_foreign_key :faultline_error_occurrences, :faultline_error_groups, column: :error_group_id
    add_foreign_key :faultline_request_profiles, :faultline_request_traces, column: :request_trace_id,
on_delete: :cascade
  end
end
