class Product < ApplicationRecord
  belongs_to :category
  has_many :options
  has_many_attached :images
end
