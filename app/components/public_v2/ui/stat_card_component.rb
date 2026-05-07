# frozen_string_literal: true

class PublicV2::Ui::StatCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(label:, value:, text: nil, variant: :default, classes: nil)
    @label = label
    @value = value
    @text = text
    @variant = variant
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
end
