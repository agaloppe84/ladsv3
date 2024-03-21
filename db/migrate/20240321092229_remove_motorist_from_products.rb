class RemoveMotoristFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :motorist, :string
  end
end
