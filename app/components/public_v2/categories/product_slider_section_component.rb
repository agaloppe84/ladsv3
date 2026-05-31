# frozen_string_literal: true

class PublicV2::Categories::ProductSliderSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(section:, debug: false)
    @section = section
    @debug = debug
  end

  private

  attr_reader :section

  def component_classes
    component_class_names(
      "pv2-category-product-section",
      "grid w-full min-w-0 gap-5",
      debug_class
    )
  end

  def product_cards
    section.products.map do |product|
      PublicV2::Ui::ProductSliderCardComponent.new(
        product: product,
        path: product_path_for(product),
        eyebrow: product_eyebrow(product),
        debug: debug?
      )
    end
  end

  def product_path_for(product)
    section.product_paths[product.id] ||
      section.product_paths[product] ||
      section.product_paths[product.to_param]
  end

  def product_eyebrow(product)
    product.manufacturers.first&.name || section.need_label
  end
end
