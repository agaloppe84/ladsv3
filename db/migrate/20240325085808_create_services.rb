class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.belongs_to :product, null: false, foreign_key: true
      t.boolean :custom_dimensions
      t.string :warranty
      t.boolean :free_quote
      t.boolean :anti_fire
      t.boolean :made_in_france
      t.boolean :anti_uv
      t.boolean :rge
      t.boolean :wind_resistance

      t.timestamps
    end
  end
end
