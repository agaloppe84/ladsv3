# frozen_string_literal: true

class PublicV2::Ui::StatCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default accent soft].freeze

  def initialize(label:, value:, text: nil, variant: :default, classes: nil, debug: false)
    @label = label
    @value = value
    @text = text
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :label, :value, :text, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-stat",
      "pv2-ui-stat--#{variant}",
      "grid w-full min-w-0 gap-[0.45rem] p-4",
      debug_class,
      classes
    )
  end
end
