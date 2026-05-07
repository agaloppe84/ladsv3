# frozen_string_literal: true

class PublicV2::Ui::BadgeComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[neutral accent service success warning destock danger].freeze
  SIZES = %i[sm md lg].freeze

  def initialize(label:, variant: :neutral, size: :md, classes: nil, debug: false)
    @label = label
    @variant = normalize_option(variant, VARIANTS, :neutral)
    @size = normalize_option(size, SIZES, :md)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :label, :variant, :size, :classes

  def component_classes
    component_class_names(
      "pv2-ui-badge",
      "pv2-ui-badge--#{variant}",
      "pv2-ui-badge--#{size}",
      "inline-flex shrink-0 items-center justify-center whitespace-nowrap text-center",
      debug_class,
      classes
    )
  end
end
