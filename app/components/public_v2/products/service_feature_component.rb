# frozen_string_literal: true

class PublicV2::Products::ServiceFeatureComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(item:, debug: false)
    @item = item
    @debug = debug
  end

  private

  attr_reader :item

  def component_classes
    component_class_names(
      "pv2-product-service-feature",
      "grid min-w-0",
      debug_class
    )
  end
end
