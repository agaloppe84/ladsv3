class RemoveBrandsFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :products, :brands
    remove_index :products, name: "index_products_on_brand_id"
    remove_column :products, :brand_id, :bigint
  end
end
