class Product < ApplicationRecord
  belongs_to :category
  has_many :options, dependent: :destroy
  has_one :service, dependent: :destroy
  has_and_belongs_to_many :rals
  has_and_belongs_to_many :motorists
  has_and_belongs_to_many :manufacturers
  has_many_attached :images
  has_many_attached :documentations

  accepts_nested_attributes_for(
    :options,
    :service,
    reject_if: :all_blank,
    allow_destroy: true
  )

  def to_param
    if persisted? && name.present?
      "#{id}-#{name.parameterize}"
    else
      super
    end
  end

end
