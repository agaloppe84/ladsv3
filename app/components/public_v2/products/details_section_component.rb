# frozen_string_literal: true

class PublicV2::Products::DetailsSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_page:, debug: false)
    @product_page = product_page
    @debug = debug
  end

  private

  attr_reader :product_page

  def component_classes
    component_class_names(
      "pv2-product-layout",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[310px_minmax(0,1fr)]",
      debug_class
    )
  end

  def technical_info_item
    product_page.information_items.find { |item| item.label == "Infos techniques" }
  end

  def palette_modal_id(index)
    "pv2-product-palette-modal-#{index + 1}"
  end

  def palette_tab_id(index)
    "pv2-product-palette-tab-#{index + 1}"
  end

  def palette_panel_id(index)
    "pv2-product-palette-panel-#{index + 1}"
  end

  def swatch_label(swatch)
    label = swatch.ref.to_s.squish.presence || swatch.title.to_s.split(/\s[-–]\s/).first.presence || swatch.name
    label.to_s.squish.sub(/\ARAL\s*/i, "").presence || "Coloris"
  end

  def swatch_title(swatch)
    [swatch.title, swatch.meta].compact_blank.join(" / ")
  end

  def palette_part_name(palette)
    label = palette.label.to_s.squish.presence || palette.code.to_s.squish.presence || "Partie"
    label.sub(/\A\p{L}/) { |letter| letter.upcase }
  end
end
