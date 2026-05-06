# frozen_string_literal: true

class PublicV2::Products::HeaderSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_page:, debug: false)
    @product_page = product_page
    @debug = debug
  end

  private

  attr_reader :product_page

  def component_classes
    ["pv2-product-header", "grid w-full min-w-0 gap-4", debug_class].compact.join(" ")
  end
end
