# frozen_string_literal: true

class PublicV2::Home::ProductRowsSectionComponent < ViewComponent::Base
  def initialize(products:)
    @products = products
  end

  def render?
    products.any?
  end

  private

  attr_reader :products
end
