# frozen_string_literal: true

class PublicV2::Products::HeroComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product:, category:, image:, color_count:, quote_path:, catalog_path:, debug: false)
    @product = product
    @category = category
    @image = image
    @color_count = color_count
    @quote_path = quote_path
    @catalog_path = catalog_path
    @debug = debug
  end

  private

  attr_reader :product, :category, :image, :color_count, :quote_path, :catalog_path

  def component_classes
    [
      "pv2-product-hero",
      "grid w-full min-w-0 grid-cols-1 items-stretch gap-4 min-[1121px]:grid-cols-[minmax(0,.82fr)_minmax(420px,1fr)]",
      debug_class
    ].compact.join(" ")
  end

  def description_text
    product.description.to_s.squish.presence ||
      product.infos.to_s.squish.presence ||
      "Produit sur mesure avec conseil, fourniture, pose et suivi par Les Artisans du Store."
  end
end
