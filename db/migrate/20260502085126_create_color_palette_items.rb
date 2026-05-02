class CreateColorPaletteItems < ActiveRecord::Migration[7.0]
  def change
    create_table :color_palette_items do |t|
      t.references :color_palette, null: false, foreign_key: true
      t.references :ral, null: false, foreign_key: true
      t.references :finish, null: true, foreign_key: true
      t.boolean :paid_option, null: false, default: false

      t.timestamps
    end
  end
end
