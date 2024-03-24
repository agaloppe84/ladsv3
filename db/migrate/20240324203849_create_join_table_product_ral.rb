class CreateJoinTableProductRal < ActiveRecord::Migration[7.0]
  def change
    create_join_table :products, :rals, id: false do |t|
      t.index :product_id
      t.index :ral_id
    end
  end
end
