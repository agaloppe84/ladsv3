# frozen_string_literal: true

class PublicV2::Categories::ProductCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(card:, debug: false)
    @card = card
    @debug = debug
  end

  private

  attr_reader :card

  delegate :product, :path, :image, :eyebrow, to: :card

  def component_classes
    component_class_names(
      "pv2-category-catalog-card",
      "min-w-0",
      debug_class
    )
  end

  def title
    product&.name.to_s.squish.presence || "Produit sur mesure"
  end

  def description_text
    helpers.truncate(card.description.to_s.squish, length: 96)
  end

  def link_label
    "Voir la fiche #{title}"
  end
end
