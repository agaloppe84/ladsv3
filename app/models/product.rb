class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  belongs_to :motorist
  has_many :options
  has_many_attached :images

  accepts_nested_attributes_for(
    :options,
    reject_if: :all_blank,
    allow_destroy: true
  )
end
