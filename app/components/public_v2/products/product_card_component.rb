# frozen_string_literal: true

class PublicV2::Products::ProductCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product:, path: nil, image: nil, fallback: "placeholder.jpg", eyebrow: nil, description: nil, classes: nil, debug: false)
    @product = product
    @path = path
    @image = image
    @fallback = fallback
    @eyebrow = eyebrow
    @description = description
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :product, :path, :image, :fallback, :eyebrow, :description, :classes

  def component_classes
    component_class_names("pv2-category-product", "pv2-ui-product-card", "grid w-full min-w-0 gap-[0.72rem]", debug_class, classes)
  end

  def title
    product&.name.presence || "Produit sur mesure"
  end

  def category_name
    eyebrow.presence || product&.category&.name.presence || "Produit"
  end

  def description_text
    source = description.presence || product&.description.presence || product&.infos.presence || "Produit sur mesure selon projet."
    helpers.truncate(source.to_s.squish, length: 86)
  end
end
