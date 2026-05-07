# frozen_string_literal: true

class PublicV2::Ui::FaqAccordionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft compact].freeze

  def initialize(items:, label: nil, variant: :default, classes: nil, debug: false)
    @items = items
    @label = label
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-faq-accordion",
      "pv2-ui-faq-accordion--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    )
  end
end
