# frozen_string_literal: true

class AdminV2::Products::RowComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  private

  attr_reader :product

  def category_name
    product.category&.name.presence || "Sans catégorie"
  end
end
