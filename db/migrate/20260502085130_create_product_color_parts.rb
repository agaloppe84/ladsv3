class CreateProductColorParts < ActiveRecord::Migration[7.0]
  def change
    create_table :product_color_parts do |t|
      t.references :product, null: false, foreign_key: true
      t.string :code, null: false
      t.string :label, null: false
      t.references :color_palette, null: false, foreign_key: true

      t.timestamps
    end
  end
end
