# frozen_string_literal: true

class PublicV2::Ui::StepRailComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[cards rail compact].freeze

  def initialize(steps:, label: nil, variant: :cards, classes: nil, debug: false)
    @steps = steps
    @label = label
    @variant = normalize_option(variant, VARIANTS, :cards)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :steps, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-step-rail",
      "pv2-ui-step-rail--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end
end
