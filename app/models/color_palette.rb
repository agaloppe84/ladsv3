class ColorPalette < ApplicationRecord
  has_many :product_color_parts, dependent: :restrict_with_error
  has_many :color_palette_items, dependent: :destroy

  has_many :rals, -> { distinct }, through: :color_palette_items
  has_many :finishes, -> { distinct }, through: :color_palette_items

  validates :name, presence: true
end
