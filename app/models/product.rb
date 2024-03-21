class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  belongs_to :motorist
  has_many :options
  has_many_attached :images
end
