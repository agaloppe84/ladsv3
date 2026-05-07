# frozen_string_literal: true

class PublicV2::Home::ProductRowsSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(products:, debug: false)
    @products = products
    @debug = debug
  end

  def render?
    products.any?
  end

  private

  attr_reader :products

  def component_classes
    [
      "pv2-home-section pv2-home-warm__specs",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
