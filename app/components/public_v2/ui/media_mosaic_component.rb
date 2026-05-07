# frozen_string_literal: true

class PublicV2::Ui::MediaMosaicComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[grid strip feature compact].freeze

  def initialize(items:, label: nil, variant: :grid, classes: nil, debug: false)
    @items = items
    @label = label
    @variant = normalize_option(variant, VARIANTS, :grid)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-media-mosaic",
      "pv2-ui-media-mosaic--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end
end
