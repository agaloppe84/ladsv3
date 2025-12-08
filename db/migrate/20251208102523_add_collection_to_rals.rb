class AddCollectionToRals < ActiveRecord::Migration[7.0]
  def change
    add_column :rals, :collection, :string, null: false, default: 'classic'
  end
end
