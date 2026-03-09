# frozen_string_literal: true

class Product::HeroComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  private

  attr_reader :product

  def images
    @images ||= product.images.first(5)
  end

  def manufacturers
    @manufacturers ||= product.manufacturers.first(6)
  end
end
