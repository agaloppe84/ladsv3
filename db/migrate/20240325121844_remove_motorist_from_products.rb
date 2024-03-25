class RemoveMotoristFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_reference :products, :motorist, null: false, foreign_key: true
  end
end
