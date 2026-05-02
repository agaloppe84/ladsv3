class Finish < ApplicationRecord
  has_many :color_palette_items, dependent: :restrict_with_error
  has_many :color_palettes, -> { distinct }, through: :color_palette_items

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :label, presence: true
end
