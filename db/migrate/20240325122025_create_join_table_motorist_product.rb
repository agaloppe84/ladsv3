class CreateJoinTableMotoristProduct < ActiveRecord::Migration[7.0]
  def change
    create_join_table :motorists, :products, id: false do |t|
      t.index :motorist_id
      t.index :product_id
    end
  end
end
