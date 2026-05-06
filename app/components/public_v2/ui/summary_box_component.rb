# frozen_string_literal: true

class PublicV2::Ui::SummaryBoxComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft flashy dark outline].freeze

  def initialize(kicker: nil, title:, text: nil, items: [], variant: :default, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @items = items
    @variant = normalize_variant(variant)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :items, :variant, :classes

  def component_classes
    [
      "pv2-ui-summary-box",
      "pv2-ui-summary-box--#{variant}",
      "grid w-full min-w-0 gap-3",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def render_items?
    items.present?
  end

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end
end
