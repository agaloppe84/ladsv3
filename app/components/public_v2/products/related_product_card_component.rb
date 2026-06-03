# frozen_string_literal: true

class PublicV2::Products::RelatedProductCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(card:, debug: false)
    @card = card
    @debug = debug
  end

  private

  attr_reader :card

  delegate :product, :path, :image, to: :card

  def component_classes
    component_class_names(
      "pv2-product-related-card",
      debug_class
    )
  end

  def title
    product&.name.to_s.squish.presence || "Produit sur mesure"
  end

  def category_name
    product&.category&.name.to_s.squish.presence || "Même gamme"
  end

  def description_text
    source = product&.description.presence || product&.infos.presence || "Comparer les options, dimensions et usages."
    helpers.truncate(source.to_s.squish, length: 72)
  end

  def link_label
    "Voir la fiche #{title}"
  end
end
