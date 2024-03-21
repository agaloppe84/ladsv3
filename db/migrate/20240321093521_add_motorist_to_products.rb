class AddMotoristToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :motorist, null: false, foreign_key: true
  end
end
