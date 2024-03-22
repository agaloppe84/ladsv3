# frozen_string_literal: true

class ProductlistComponent < ViewComponent::Base

  def initialize(products)
    @products = products
  end

end
