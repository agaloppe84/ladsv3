# frozen_string_literal: true

class PublicV2::HomePage
  CategoryCard = Struct.new(:category, :index, :cover_image, :product_count, keyword_init: true) do
    def number
      format("%02d", index + 1)
    end

    def description
      category.description.to_s.squish.presence || "Solutions sur mesure avec conseil et pose."
    end
  end

  def initialize(categories:, products:, destock_products:, featured_product:, category_product_counts:, category_cover_products:, primary_image_resolver:)
    @categories = categories
    @products = products
    @destock_products = destock_products
    @featured_product = featured_product
    @category_product_counts = category_product_counts
    @category_cover_products = category_cover_products
    @primary_image_resolver = primary_image_resolver
  end

  attr_reader :categories, :products

  def featured_product
    @featured_product || products.first
  end

  def featured_image
    primary_image_for(featured_product)
  end

  def quote_product_options
    quote_products.map { |product| [product.name, product.id] }
  end

  def quote_product_selected_id
    featured_product&.id
  end

  def category_cards
    @category_cards ||= categories.first(6).map.with_index do |category, index|
      CategoryCard.new(
        category: category,
        index: index,
        cover_image: primary_image_for(@category_cover_products[category.id]),
        product_count: @category_product_counts[category.id].to_i
      )
    end
  end

  def product_rows
    products.first(6)
  end

  private

  attr_reader :destock_products, :primary_image_resolver

  def quote_products
    (products + destock_products).uniq.first(12)
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end
end
