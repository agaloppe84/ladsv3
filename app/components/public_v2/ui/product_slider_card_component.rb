# frozen_string_literal: true

class PublicV2::Ui::ProductSliderCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product:, path: nil, eyebrow: nil, description: nil, classes: nil, debug: false)
    @product = product
    @path = path
    @eyebrow = eyebrow
    @description = description
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :product, :path, :eyebrow, :description, :classes

  def component_classes
    component_class_names(
      "pv2-ui-product-slider-card",
      "grid min-w-0",
      ("pv2-ui-product-slider-card--interactive" if link?),
      debug_class,
      classes
    )
  end

  def link?
    path.present?
  end

  def link_label
    "Voir #{title}"
  end

  def title
    product&.name.presence || "Produit sur mesure"
  end

  def kicker
    eyebrow.presence || product&.manufacturers&.first&.name || product&.category&.name
  end

  def description_text
    source = description.presence || product&.description.presence || product&.infos.presence || "Produit sur mesure selon projet."
    helpers.truncate(source.to_s.squish, length: 150)
  end
end
