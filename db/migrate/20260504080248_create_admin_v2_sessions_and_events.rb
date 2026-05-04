class CreateAdminV2SessionsAndEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_v2_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :last_seen_at, null: false
      t.datetime :ended_at
      t.string :status, null: false, default: "active"
      t.string :ip_address
      t.text :user_agent
      t.string :current_area
      t.string :current_resource_type
      t.bigint :current_resource_id
      t.integer :events_count, null: false, default: 0
      t.integer :mutations_count, null: false, default: 0
      t.integer :errors_count, null: false, default: 0
      t.integer :uploads_count, null: false, default: 0
      t.integer :autosaves_count, null: false, default: 0

      t.timestamps
    end

    add_index :admin_v2_sessions, [:user_id, :status, :last_seen_at]
    add_index :admin_v2_sessions, [:current_resource_type, :current_resource_id], name: "idx_admin_v2_sessions_on_current_resource"

    create_table :admin_v2_session_events do |t|
      t.references :admin_v2_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :level, null: false
      t.string :event_type, null: false
      t.string :resource_type
      t.bigint :resource_id
      t.string :request_method
      t.string :request_path
      t.integer :status_code
      t.text :message, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :admin_v2_session_events, [:admin_v2_session_id, :created_at], name: "index_admin_v2_events_on_session_and_created_at"
    add_index :admin_v2_session_events, [:user_id, :created_at], name: "index_admin_v2_events_on_user_and_created_at"
    add_index :admin_v2_session_events, [:resource_type, :resource_id], name: "index_admin_v2_events_on_resource"
  end
end
