class AddActiveToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :active, :boolean, null: false, default: true
    change_column_default :categories, :active, from: true, to: false
  end
end
