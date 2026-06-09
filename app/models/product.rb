class Product < ApplicationRecord
  belongs_to :category
  has_many :options, dependent: :destroy
  has_one :service, dependent: :destroy
  has_and_belongs_to_many :rals
  has_many :product_color_parts, dependent: :destroy
  has_many :color_palettes, -> { distinct }, through: :product_color_parts
  has_and_belongs_to_many :motorists
  has_and_belongs_to_many :manufacturers
  has_one_attached :front_image
  has_many_attached :images
  has_many_attached :documentations

  accepts_nested_attributes_for(
    :options,
    :service,
    reject_if: :all_blank,
    allow_destroy: true
  )

  before_validation :assign_slug, on: :create

  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  def ordered_images
    images.attachments.includes(:blob).order(:position, :id)
  end

  def primary_image
    ordered_images.first
  end

  def sync_image_positions!(signed_ids)
    signed_ids = Array(signed_ids).reject(&:blank?)
    blob_ids_by_signed_id = image_blob_ids_by_signed_id(signed_ids)
    return if blob_ids_by_signed_id.empty?

    position_by_blob_id = {}

    signed_ids.each_with_index do |signed_id, index|
      blob_id = blob_ids_by_signed_id[signed_id]
      position_by_blob_id[blob_id] = index + 1 if blob_id
    end

    images.attachments.where(blob_id: position_by_blob_id.keys).find_each do |attachment|
      position = position_by_blob_id[attachment.blob_id]
      attachment.update_column(:position, position) if position && attachment.position != position
    end
  end

  private

  def image_blob_ids_by_signed_id(signed_ids)
    signed_ids.each_with_object({}) do |signed_id, blob_ids|
      blob = ActiveStorage::Blob.find_signed(signed_id)
      blob_ids[signed_id] = blob.id if blob
    end
  end

  def assign_slug
    return if slug.present?

    base_slug = name.to_s.parameterize.presence || "product"
    candidate = base_slug
    suffix = 2

    while Product.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base_slug}-#{suffix}"
      suffix += 1
    end

    self.slug = candidate
  end
end
