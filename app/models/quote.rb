class Quote < ApplicationRecord
  validates_presence_of :email, :lastname, :address, :city, :phone, :product, :message
end
