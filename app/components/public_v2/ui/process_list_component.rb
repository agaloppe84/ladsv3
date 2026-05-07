# frozen_string_literal: true

class PublicV2::Ui::ProcessListComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[cards rail timeline compact].freeze

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
      "pv2-ui-process-list",
      "pv2-ui-process-list--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end

  def step_kicker(step, index)
    step[:kicker].presence || Kernel.format("%02d", index + 1)
  end
end
