class CreateRals < ActiveRecord::Migration[7.0]
  def change
    create_table :rals do |t|
      t.string :name
      t.string :name_en
      t.string :ref
      t.string :rgb
      t.string :hex

      t.timestamps
    end
  end
end
