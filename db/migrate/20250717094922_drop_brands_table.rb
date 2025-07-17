class DropBrandsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :brands
  end

  def down
    create_table :brands do |t|
      t.string   :name
      t.string   :logo
      t.timestamps
    end
  end
end
