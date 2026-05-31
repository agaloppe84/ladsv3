# frozen_string_literal: true

class PublicV2::Ui::NeedGridComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(items:, kicker:, title:, text:, label: "Entrer par besoin", classes: nil, debug: false)
    @items = items
    @kicker = kicker
    @title = title
    @text = text
    @label = label
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :kicker, :title, :text, :label, :classes

  def component_classes
    component_class_names(
      "pv2-ui-need-grid",
      "pv2-category-needs",
      "grid w-full min-w-0 gap-4",
      debug_class,
      classes
    )
  end

  def item_classes(item)
    component_class_names(
      "pv2-ui-need-grid__item",
      "pv2-category-needs__item",
      "pv2-category-needs__item--#{item.accent_role}"
    )
  end

  def item_links(item)
    item.category_names.zip(item.anchor_hrefs)
  end
end
