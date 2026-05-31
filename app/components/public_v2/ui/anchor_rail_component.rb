# frozen_string_literal: true

class PublicV2::Ui::AnchorRailComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default minimal].freeze

  def initialize(items:, kicker:, title:, text:, label: "Navigation", variant: :default, classes: nil, debug: false)
    @items = items
    @kicker = kicker
    @title = title
    @text = text
    @label = label
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :kicker, :title, :text, :label, :variant, :classes

  def component_classes
    component_class_names(
      "pv2-ui-anchor-rail",
      "pv2-category-anchor-rail",
      "pv2-category-anchor-rail--#{variant}",
      "grid w-full min-w-0 gap-3",
      debug_class,
      classes
    )
  end

  def item_classes(item, active: false)
    component_class_names(
      "pv2-ui-anchor-rail__item",
      "pv2-category-anchor-rail__item",
      "pv2-category-anchor-rail__item--#{item.accent_role}",
      ("is-active" if active)
    )
  end

  def minimal?
    variant == :minimal
  end
end
