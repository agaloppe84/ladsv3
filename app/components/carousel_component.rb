# frozen_string_literal: true

class CarouselComponent < ViewComponent::Base

  def initialize(products)
    @products = products
  end

  def render?
    @products.any?
  end

end
