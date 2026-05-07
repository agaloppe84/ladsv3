# frozen_string_literal: true

class PublicV2::Ui::ProofRailComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default compact soft].freeze

  def initialize(items:, label: nil, variant: :default, classes: nil, debug: false)
    @items = items
    @label = label
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-proof-rail",
      "pv2-ui-proof-rail--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end
end
