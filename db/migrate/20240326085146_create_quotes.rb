class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes do |t|
      t.string :lastname
      t.string :address
      t.string :city
      t.string :phone
      t.string :email
      t.string :product
      t.string :message

      t.timestamps
    end
  end
end
