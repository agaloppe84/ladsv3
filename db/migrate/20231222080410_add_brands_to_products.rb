class AddBrandsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :brand, :string
    add_column :products, :motorist, :string
  end
end
