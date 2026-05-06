# frozen_string_literal: true

class PublicV2::QuotePage
  def initialize(quote:, products:, selected_product:, selected_product_image:)
    @quote = quote
    @products = products
    @selected_product = selected_product
    @selected_product_image = selected_product_image
  end

  attr_reader :quote, :products, :selected_product, :selected_product_image

  def selected_product?
    selected_product.present?
  end

  def selected_product_category_name
    selected_product&.category&.name.presence || "Produit"
  end
end
