class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  has_many :options, dependent: :destroy
  has_one :service
  has_and_belongs_to_many :rals
  has_and_belongs_to_many :motorists
  has_many_attached :images

  accepts_nested_attributes_for(
    :options,
    :rals,
    :service,
    reject_if: :all_blank,
    allow_destroy: true
  )
end
