# frozen_string_literal: true

class Product::BrandsComponent < ViewComponent::Base
  def initialize(manufacturers:)
    @manufacturers = manufacturers
  end

  def render?
    @manufacturers.any?
  end
end
