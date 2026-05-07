# frozen_string_literal: true

class PublicV2::Content::InfoCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[contact default].freeze

  def initialize(label:, title:, text: nil, path: nil, variant: :contact, classes: nil, debug: false)
    @label = label
    @title = title
    @text = text
    @path = path
    @variant = normalize_option(variant, VARIANTS, :contact)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :label, :title, :text, :path, :variant, :classes

  def component_classes
    component_class_names(
      variant == :contact ? "pv2-contact-card" : "pv2-ui-info-card__surface",
      "pv2-ui-info-card",
      "pv2-ui-info-card--#{variant}",
      "grid w-full min-w-0 gap-[0.44rem] p-4",
      debug_class,
      classes
    )
  end
end
