# frozen_string_literal: true

class AdminV2::Products::IndexComponent < ViewComponent::Base
  def initialize(products:)
    @products = products
  end

  private

  attr_reader :products
end
