class AddInfosToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :infos, :string
    add_column :products, :warranty, :string
  end
end
