# frozen_string_literal: true

class PublicV2::Ui::BreadcrumbComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(items:, label: "Fil d'Ariane", classes: nil, debug: false)
    @items = items
    @label = label
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :classes

  def component_classes
    component_class_names("pv2-public-breadcrumb", "pv2-ui-breadcrumb", "flex w-full min-w-0 flex-wrap items-center gap-[0.42rem]", debug_class, classes)
  end

  def last_item?(index)
    index == items.size - 1
  end

  def item_label(item)
    item[:label]
  end

  def item_path(item)
    item[:path]
  end
end
