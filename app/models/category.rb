class Category < ApplicationRecord
  has_many :products

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
