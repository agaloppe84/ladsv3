# frozen_string_literal: true

class PublicV2::Products::CategoryBlockComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category:, products: [], image: nil, title: nil, text: nil, kicker: nil, tags: [], product_paths: {}, product_images: {}, empty_message: nil, classes: nil)
    @category = category
    @products = products
    @image = image
    @title = title
    @text = text
    @kicker = kicker
    @tags = tags
    @product_paths = product_paths
    @product_images = product_images
    @empty_message = empty_message
    @classes = classes
  end

  private

  attr_reader :category, :products, :image, :title, :text, :kicker, :tags, :product_paths, :product_images, :empty_message, :classes

  def component_classes
    ["pv2-category-block", "pv2-ui-category-block", "grid w-full min-w-0 gap-4 p-4", debug_class, classes].compact.join(" ")
  end

  def category_name
    title.presence || category&.name.presence || "Famille de produits"
  end

  def description_text
    text.presence || category&.description.presence || "Des solutions a comparer selon l'usage, la pose et les contraintes du projet."
  end

  def kicker_text
    kicker.presence || "Produits"
  end

  def tag_labels
    return tags if tags.any?

    products.first(4).map { |product| product.category&.name || product.name }.uniq
  end

  def product_path_for(product)
    product_paths[product.id] || product_paths[product] || product_paths[product.to_param]
  end

  def product_image_for(product)
    product_images[product.id] || product_images[product] || product_images[product.to_param]
  end

  def product_eyebrow(product)
    product.manufacturers.first&.name || product.category&.name
  end
end
