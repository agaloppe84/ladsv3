# frozen_string_literal: true

class PublicV2::Content::InfoCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(label:, title:, text: nil, path: nil, variant: :contact, classes: nil)
    @label = label
    @title = title
    @text = text
    @path = path
    @variant = variant
    @classes = classes
  end

  private

  attr_reader :label, :title, :text, :path, :variant, :classes

  def component_classes
    [
      variant == :contact ? "pv2-contact-card" : "pv2-ui-info-card__surface",
      "pv2-ui-info-card",
      "pv2-ui-info-card--#{variant}",
      "grid w-full min-w-0 gap-[0.44rem] p-4",
      debug_class,
      classes
    ].compact.join(" ")
  end
end
