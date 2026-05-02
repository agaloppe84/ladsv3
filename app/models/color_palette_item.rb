class ColorPaletteItem < ApplicationRecord
  belongs_to :color_palette
  belongs_to :ral
  belongs_to :finish, optional: true

  validates :paid_option, inclusion: { in: [true, false] }
end
