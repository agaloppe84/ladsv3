class AddPositionToActiveStorageAttachments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    unless column_exists?(:active_storage_attachments, :position)
      add_column :active_storage_attachments, :position, :integer
    end

    execute <<~SQL.squish
      WITH ranked_attachments AS (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY record_type, record_id, name
            ORDER BY created_at ASC, id ASC
          ) AS row_position
        FROM active_storage_attachments
        WHERE position IS NULL
      )
      UPDATE active_storage_attachments
      SET position = ranked_attachments.row_position
      FROM ranked_attachments
      WHERE active_storage_attachments.id = ranked_attachments.id
    SQL

    unless index_exists?(:active_storage_attachments, [:record_type, :record_id, :name, :position], name: "index_active_storage_attachments_on_record_and_position")
      add_index(
        :active_storage_attachments,
        [:record_type, :record_id, :name, :position],
        name: "index_active_storage_attachments_on_record_and_position",
        algorithm: :concurrently
      )
    end
  end

  def down
    if index_exists?(:active_storage_attachments, name: "index_active_storage_attachments_on_record_and_position")
      remove_index :active_storage_attachments, name: "index_active_storage_attachments_on_record_and_position"
    end

    remove_column :active_storage_attachments, :position if column_exists?(:active_storage_attachments, :position)
  end
end
