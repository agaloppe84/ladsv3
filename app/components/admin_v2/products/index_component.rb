# frozen_string_literal: true

class AdminV2::Products::IndexComponent < ViewComponent::Base
  def initialize(products:, pagination: nil)
    @products = products
    @pagination = pagination
  end

  private

  attr_reader :products, :pagination
end
