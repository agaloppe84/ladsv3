# frozen_string_literal: true

class Product::SpecsComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  def render?
    @product.infos.present? || @product.options.any?
  end
end
