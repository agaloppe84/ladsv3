# frozen_string_literal: true

class PublicV2::Ui::StatCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default accent soft].freeze

  def initialize(label:, value:, text: nil, variant: :default, classes: nil)
    @label = label
    @value = value
    @text = text
    @variant = normalize_variant(variant)
    @classes = classes
  end

  private

  attr_reader :label, :value, :text, :variant, :classes

  def component_classes
    [
      "pv2-ui-stat",
      "pv2-ui-stat--#{variant}",
      "grid w-full min-w-0 gap-[0.45rem] p-4",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def normalize_variant(value)
    normalized_value = value.to_s.to_sym
    VARIANTS.include?(normalized_value) ? normalized_value : :default
  end
end
