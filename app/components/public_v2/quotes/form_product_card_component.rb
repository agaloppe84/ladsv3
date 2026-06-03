# frozen_string_literal: true

class PublicV2::Quotes::FormProductCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product:, image:, debug: false)
    @product = product
    @image = image
    @debug = debug
  end

  private

  attr_reader :product, :image

  def component_classes
    component_class_names("pv2-quote-form-product-card", debug_class)
  end

  def title
    product&.name.to_s.squish.presence || "Produit selectionne"
  end

  def category_name
    product&.category&.name.to_s.squish.presence || "Produit"
  end

  def description_text
    source = product&.description.presence || product&.infos.presence || "Produit retenu pour cadrer votre demande."
    helpers.truncate(source.to_s.squish, length: 82)
  end

  def product_path
    return if product.blank? || product.type.present? || product.slug.blank?

    helpers.public_v2_product_path(slug: product.slug)
  end

  def link_label
    "Voir la fiche #{title}"
  end
end
