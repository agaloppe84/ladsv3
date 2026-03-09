# frozen_string_literal: true

class Product::BottomCtaComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end
end
