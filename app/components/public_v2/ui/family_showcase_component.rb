# frozen_string_literal: true

class PublicV2::Ui::FamilyShowcaseComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(section:, cta_path:, classes: nil, debug: false)
    @section = section
    @cta_path = cta_path
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :section, :cta_path, :classes

  def component_classes
    component_class_names(
      "pv2-ui-family-showcase",
      "pv2-family-showcase",
      "pv2-family-showcase--#{section.accent_role}",
      "grid w-full min-w-0",
      debug_class,
      classes
    )
  end

  def product_path_for(product)
    section.featured_product_paths[product.id] ||
      section.featured_product_paths[product] ||
      section.featured_product_paths[product.to_param]
  end

  def product_image_for(product)
    section.featured_product_images[product.id] ||
      section.featured_product_images[product] ||
      section.featured_product_images[product.to_param]
  end

  def product_eyebrow(product)
    product.manufacturers.first&.name || section.short_title
  end

  def product_description(product)
    source = product.description.presence || product.infos.presence || "Produit sur mesure selon projet."
    helpers.truncate(source.to_s.squish, length: 78)
  end

  def remaining_text
    return "Selection courte pour comparer rapidement." unless section.has_more_products?

    "+ #{section.remaining_product_count} autres references dans cette famille."
  end
end
