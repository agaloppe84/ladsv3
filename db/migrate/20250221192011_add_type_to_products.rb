class AddTypeToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :type, :string
    add_column :products, :dimensions, :string
    add_column :products, :old_price, :string
    add_column :products, :new_price, :string
  end
end
