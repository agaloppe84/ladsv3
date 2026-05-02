# frozen_string_literal: true

class Product::ConfigurationComponent < ViewComponent::Base
  def initialize(product:, product_color_parts:)
    @product = product
    @product_color_parts = product_color_parts
  end

  def render?
    show_specs? || parts.any?
  end

  private

  attr_reader :product, :product_color_parts

  def parts
    @parts ||= product_color_parts.sort_by(&:created_at)
  end

  def show_specs?
    product.infos.present? || product.options.any?
  end

  def initial_tab
    return "specs" if show_specs?

    first_part = parts.first
    return part_tab_id(first_part) if first_part

    "specs"
  end

  def part_tab_id(part)
    "part-#{part.id}"
  end

  def part_tab_label(part)
    "Coloris #{part_display_name(part).to_s.downcase}"
  end

  def part_display_name(part)
    part.label.presence || part.code.presence || "part"
  end

  def part_modal_title(part)
    "Tous les coloris #{part_display_name(part).to_s.downcase}"
  end

  def items_for(part)
    @items_for ||= {}
    @items_for[part.id] ||= begin
      items = part.color_palette&.color_palette_items&.to_a || []
      items.sort_by { |item| [item.ral&.collection.to_s, item.ral&.ref.to_s, item.finish&.label.to_s] }
    end
  end

  def rals_for(part)
    @rals_for ||= {}
    @rals_for[part.id] ||= items_for(part).map(&:ral).compact.uniq { |ral| [ral.id, ral.ref, ral.name, ral.hex] }
  end

  def preview_rals_for(part)
    rals_for(part).first(16)
  end

  def hidden_rals_count(part)
    [rals_for(part).size - 16, 0].max
  end

  def swatch_color(ral)
    ral.hex.presence || "#e2e8f0"
  end

  def show_canvas_selector?
    product.manufacturers.any? { |manufacturer| manufacturer.name.to_s.downcase.include?("dickson") }
  end
end
