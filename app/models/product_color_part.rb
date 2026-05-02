class ProductColorPart < ApplicationRecord
  belongs_to :product
  belongs_to :color_palette

  validates :code, presence: true, uniqueness: { scope: :product_id, case_sensitive: false }
  validates :label, presence: true
end
