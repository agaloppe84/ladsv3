# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  HERO_PRODUCT_CARDS = [
    {
      key: "interior-blind",
      label: "Store intérieur",
      image: "public_v2/hero-interior-blind-closeup-cgi.png",
      alt: "Store intérieur premium type Duette en gros plan sur fond blanc",
      kicker: "Store intérieur",
      title: "Lumière",
      accent_title: "maîtrisée",
      accent: "var(--pv2-style-accent-fresh)"
    },
    {
      key: "pergola",
      label: "Pergola",
      image: "public_v2/hero-pergola-closeup-cgi.png",
      alt: "Pergola bioclimatique premium en gros plan vue de dessus sur fond blanc",
      kicker: "Pergola",
      title: "Ombre",
      accent_title: "précise",
      accent: "var(--pv2-style-accent-orange)"
    },
    {
      key: "mosquito-screen",
      label: "Moustiquaire",
      image: "public_v2/hero-mosquito-screen-closeup-cgi.png",
      alt: "Moustiquaire premium en gros plan vue de face sur fond blanc",
      kicker: "Moustiquaire",
      title: "Air frais",
      accent_title: "protégé",
      accent: "var(--pv2-style-accent-3)"
    },
    {
      key: "awning-box",
      label: "Store coffre",
      image: "public_v2/hero-awning-box-closeup-cgi.png",
      alt: "Store banne coffre premium en gros plan vue de dessus sur fond blanc",
      kicker: "Store coffre",
      title: "Terrasse",
      accent_title: "ombragée",
      accent: "var(--pv2-style-accent-orange)"
    }
  ].freeze
  HERO_PRODUCT_INITIAL_KEY = "interior-blind"
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
    }
  ].freeze

  def initialize(home_page:, event: nil, debug: false)
    @home_page = home_page
    @event = event
    @debug = debug
  end

  private

  attr_reader :home_page, :event

  def hero_product_cards
    HERO_PRODUCT_CARDS
  end

  def hero_product_initial_index
    HERO_PRODUCT_CARDS.index { |card| card[:key] == HERO_PRODUCT_INITIAL_KEY } || 0
  end

  def hero_product_initial_card
    HERO_PRODUCT_CARDS[hero_product_initial_index]
  end

  def hero_fact_items
    HERO_FACT_ITEMS
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
