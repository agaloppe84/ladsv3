# frozen_string_literal: true

class PublicV2::Products::AnimatedServiceCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[fire rge uv warranty wind].freeze

  def initialize(item:, debug: false)
    @item = item
    @debug = debug
  end

  private

  attr_reader :item

  def variant
    value = item.variant.to_s.to_sym
    return value if VARIANTS.include?(value)

    :wind
  end

  def protected_label
    item.protected_label.to_s.squish
  end

  def impact_label
    item.impact_label.to_s.squish
  end

  def component_classes
    component_class_names(
      "pv2-product-animated-service-card",
      "pv2-product-animated-service-card--#{variant}",
      debug_class
    )
  end
end
