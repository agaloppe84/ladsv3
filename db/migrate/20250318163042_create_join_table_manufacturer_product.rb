class CreateJoinTableManufacturerProduct < ActiveRecord::Migration[7.0]
  def change
    create_join_table :manufacturers, :products do |t|
      # t.index [:manufacturer_id, :product_id]
      # t.index [:product_id, :manufacturer_id]
    end
  end
end
