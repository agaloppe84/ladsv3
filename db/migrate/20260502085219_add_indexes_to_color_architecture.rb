class AddIndexesToColorArchitecture < ActiveRecord::Migration[7.0]
  def change
    add_index :finishes, :code, unique: true

    add_index :product_color_parts,
              [:product_id, :code],
              unique: true,
              name: "idx_product_color_parts_product_code"

    add_index :color_palette_items,
              [:color_palette_id, :ral_id, :finish_id],
              unique: true,
              where: "finish_id IS NOT NULL",
              name: "idx_cpi_palette_ral_finish_uniq"

    add_index :color_palette_items,
              [:color_palette_id, :ral_id],
              unique: true,
              where: "finish_id IS NULL",
              name: "idx_cpi_palette_ral_no_finish_uniq"
  end
end
