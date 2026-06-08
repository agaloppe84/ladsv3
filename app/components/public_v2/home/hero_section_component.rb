# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  HERO_FACT_ITEMS = [
    {
      variant: :accent,
      value: "48h",
      text: "Devis gratuit"
    },
    {
      variant: :contrast,
      value: "200m2",
      text: "Showroom"
    },
    {
      variant: :plain,
      value: "RGE",
      text: "Expert"
    },
    {
      variant: :orange,
      value: "SAV",
      text: "Pose"
    }
  ].freeze

  def initialize(home_page:, event: nil, debug: false)
    @home_page = home_page
    @event = event
    @debug = debug
  end

  private

  attr_reader :home_page, :event

  def hero_category_cards
    home_page.hero_category_cards
  end

  def hero_category_initial_index
    home_page.hero_category_initial_index
  end

  def hero_category_initial_card
    hero_category_cards[hero_category_initial_index]
  end

  def hero_category_initial_accent
    hero_category_initial_card&.accent || "var(--pv2-style-accent-fresh)"
  end

  def hero_fact_items
    HERO_FACT_ITEMS
  end

  def cloudinary_image?(image)
    image.present? && image.respond_to?(:key)
  end

  def component_classes
    component_class_names(
      "pv2-home-warm__hero pv2-home-hero-v2",
      ("pv2-home-hero-v2--with-event" if event.present?),
      "grid w-full min-w-0 gap-4",
      debug_class
    )
  end
end
