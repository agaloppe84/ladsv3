# frozen_string_literal: true

class PublicV2::Ui::BadgeComponent < ViewComponent::Base
  def initialize(label:, variant: :neutral, size: :md, classes: nil)
    @label = label
    @variant = variant
    @size = size
    @classes = classes
  end

  private

  attr_reader :label, :variant, :size, :classes

  def component_classes
    [
      "pv2-ui-badge",
      "pv2-ui-badge--#{variant}",
      "pv2-ui-badge--#{size}",
      "inline-flex shrink-0 items-center justify-center whitespace-nowrap text-center",
      classes
    ].compact.join(" ")
  end
end
