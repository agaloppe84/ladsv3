class Category < ApplicationRecord
  has_one_attached :hero_image

  has_many :products

  scope :published, -> { where(active: true) }
  scope :draft, -> { where(active: false) }

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
