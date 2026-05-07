# frozen_string_literal: true

class PublicV2::Home::CategoryGridSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category_cards:, debug: false)
    @category_cards = category_cards
    @debug = debug
  end

  private

  attr_reader :category_cards

  def family_items
    category_cards.map do |card|
      {
        kicker: card.number,
        title: card.category.name,
        text: card.description,
        meta: "#{card.product_count} produits references",
        image: card.cover_image,
        alt: card.category.name,
        path: helpers.public_v2_categories_path(anchor: "categorie-#{card.category.id}")
      }
    end
  end

  def component_classes
    component_class_names(
      "pv2-home-section pv2-home-warm__catalog",
      "grid w-full min-w-0 gap-5",
      debug_class
    )
  end
end
