# frozen_string_literal: true

class PublicV2::Products::AnimatedServiceCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[wind uv].freeze

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

  def wind?
    variant == :wind
  end

  def uv?
    variant == :uv
  end

  def protected_label
    wind? ? "Résistance au" : "Protection"
  end

  def impact_label
    wind? ? "Vent" : "UV"
  end

  def component_classes
    component_class_names(
      "pv2-product-animated-service-card",
      "pv2-product-animated-service-card--#{variant}",
      "pv2-product-side__card",
      debug_class
    )
  end
end
