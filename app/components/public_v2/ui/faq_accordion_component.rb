# frozen_string_literal: true

class PublicV2::Ui::FaqAccordionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft compact].freeze

  def initialize(items:, label: nil, variant: :default, classes: nil, debug: false)
    @items = items
    @label = label
    @variant = normalize_variant(variant)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :variant, :classes

  def component_classes
    [
      "pv2-ui-faq-accordion",
      "pv2-ui-faq-accordion--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end
end
