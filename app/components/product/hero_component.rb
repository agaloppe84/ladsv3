# frozen_string_literal: true

class Product::HeroComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  private

  attr_reader :product

  def gallery_photos
    @gallery_photos ||= product.images.first(4)
  end

  def description_text
    return product.description if product.description.present?
    return product.infos if product.infos.present?

    "Découvrez la configuration complète du produit, ses coloris, finitions et documentations associées."
  end
end
