class CreateMotorists < ActiveRecord::Migration[7.0]
  def change
    create_table :motorists do |t|
      t.string :name
      t.string :logo

      t.timestamps
    end
  end
end
