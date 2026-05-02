class CreateFinishes < ActiveRecord::Migration[7.0]
  def change
    create_table :finishes do |t|
      t.string :code, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
