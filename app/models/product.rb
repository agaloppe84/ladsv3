class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  belongs_to :motorist
  has_many :options
  has_one :service
  has_and_belongs_to_many :rals
  has_many_attached :images

  accepts_nested_attributes_for(
    :options,
    :rals,
    reject_if: :all_blank,
    allow_destroy: true
  )
end
