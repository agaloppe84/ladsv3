# frozen_string_literal: true

class Product::TestShowHeroComponent < ViewComponent::Base
  def initialize(product:, product_color_parts:)
    @product = product
    @product_color_parts = product_color_parts
  end

  private

  attr_reader :product, :product_color_parts

  def gallery_photos
    @gallery_photos ||= product.images.first(4)
  end

  def parts_count
    @parts_count ||= product_color_parts.size
  end

  def colors_count
    @colors_count ||= product_color_parts.sum do |part|
      part.color_palette&.color_palette_items&.size.to_i
    end
  end

  def paid_options_count
    @paid_options_count ||= product_color_parts.sum do |part|
      items = part.color_palette&.color_palette_items&.to_a || []
      items.count(&:paid_option)
    end
  end

  def show_canvas_selector?
    product.manufacturers.any? { |manufacturer| manufacturer.name.to_s.downcase.include?("dickson") }
  end

  def description_text
    return product.description if product.description.present?
    return product.infos if product.infos.present?

    "Découvrez la configuration complète du produit, ses coloris, finitions et documentations associées."
  end
end
