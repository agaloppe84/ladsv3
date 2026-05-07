# frozen_string_literal: true

class PublicV2::Products::DetailsSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_page:, debug: false)
    @product_page = product_page
    @debug = debug
  end

  private

  attr_reader :product_page

  def component_classes
    component_class_names(
      "pv2-product-layout",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[310px_minmax(0,1fr)]",
      debug_class
    )
  end
end
