# frozen_string_literal: true

class Product::TestColorPartsComponent < ViewComponent::Base
  def initialize(product_color_parts:)
    @product_color_parts = product_color_parts
  end

  private

  attr_reader :product_color_parts

  def parts
    @parts ||= product_color_parts.sort_by(&:created_at)
  end

  def items_for(part)
    @items_for ||= {}
    @items_for[part.id] ||= begin
      items = part.color_palette&.color_palette_items&.to_a || []
      items.sort_by { |item| [item.ral&.collection.to_s, item.ral&.ref.to_s, item.finish&.label.to_s] }
    end
  end

  def swatch_color(item)
    item.ral&.hex.presence || "#e2e8f0"
  end

  def finish_label(item)
    item.finish&.label.presence || "Sans finition"
  end

  def status_label(item)
    item.paid_option ? "Option payante" : "Inclus"
  end

  def status_classes(item)
    if item.paid_option
      "border-amber-200 bg-amber-50 text-amber-700"
    else
      "border-emerald-200 bg-emerald-50 text-emerald-700"
    end
  end
end
