class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  has_many :options, dependent: :destroy
  has_one :service, dependent: :destroy
  has_and_belongs_to_many :rals
  has_and_belongs_to_many :motorists
  has_many_attached :images
  validate :validate_image_size

  accepts_nested_attributes_for(
    :options,
    :service,
    reject_if: :all_blank,
    allow_destroy: true
  )

  private

  def validate_image_size
    images.each do |image|
      if image.blob.byte_size > 10.megabytes # Ajuste la limite selon tes besoins
        errors.add(:images, "#{image.filename} est trop volumineux. Taille max: 10 MB")
      end
    end
  end
end
