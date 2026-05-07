# frozen_string_literal: true

class PublicV2::Ui::ProductFamilyGridComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft editorial compact].freeze

  def initialize(families:, label: nil, variant: :default, classes: nil, debug: false)
    @families = families
    @label = label
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :families, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-product-family-grid",
      "pv2-ui-product-family-grid--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end

  def family_number(family, index)
    family[:kicker].presence || Kernel.format("%02d", index + 1)
  end
end
