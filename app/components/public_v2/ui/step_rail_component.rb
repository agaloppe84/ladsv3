# frozen_string_literal: true

class PublicV2::Ui::StepRailComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[cards rail compact].freeze

  def initialize(steps:, label: nil, variant: :cards, classes: nil, debug: false)
    @steps = steps
    @label = label
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :cards
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :steps, :label, :variant, :classes

  def component_classes
    [
      "pv2-ui-step-rail",
      "pv2-ui-step-rail--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    ].compact.join(" ")
  end
end
