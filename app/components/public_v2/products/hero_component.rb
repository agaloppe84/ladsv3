# frozen_string_literal: true

class PublicV2::Products::HeroComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_page:, debug: false)
    @product_page = product_page
    @debug = debug
  end

  private

  attr_reader :product_page

  delegate :product, :category, :quote_path, :catalog_path, to: :product_page

  def component_classes
    [
      "pv2-product-hero pv2-product-hero-v2",
      "grid w-full min-w-0 grid-cols-1 items-stretch gap-4 min-[1121px]:grid-cols-[minmax(0,.78fr)_minmax(380px,.62fr)]",
      debug_class
    ].compact.join(" ")
  end

  def image
    product_page.hero_image
  end

  def description_text
    product.description.to_s.squish.presence ||
      product.infos.to_s.squish.presence ||
      "Produit sur mesure avec conseil, fourniture, pose et suivi par Les Artisans du Store."
  end
end
