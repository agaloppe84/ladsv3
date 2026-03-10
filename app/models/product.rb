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

  before_validation :assign_slug, on: :create

  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  private

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
