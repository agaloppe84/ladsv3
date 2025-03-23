class Quote < ApplicationRecord
  validates_presence_of :email, :lastname, :address, :city, :phone, :product, :message
  after_create_commit { broadcast_prepend_to "admin_quotes" }
end
