# frozen_string_literal: true

class PublicV2::Ui::ProductFamilyGridComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft editorial compact].freeze

  def initialize(families:, label: nil, variant: :default, classes: nil, debug: false)
    @families = families
    @label = label
    @variant = normalize_variant(variant)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :families, :label, :variant, :classes

  def component_classes
    [
      "pv2-ui-product-family-grid",
      "pv2-ui-product-family-grid--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def family_number(family, index)
    family[:kicker].presence || Kernel.format("%02d", index + 1)
  end

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end
end
