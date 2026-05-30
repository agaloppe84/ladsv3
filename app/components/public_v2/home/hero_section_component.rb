# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  HERO_PRODUCT_CARDS = [
    {
      key: "interior-blind",
      label: "Store interieur",
      image: "public_v2/hero-interior-blind-closeup-cgi.png",
      alt: "Store interieur premium type Duette en gros plan sur fond blanc",
      kicker: "Store interieur",
      title: "Lumiere",
      accent_title: "maitrisee",
      accent: "#ff3b30"
    },
    {
      key: "pergola",
      label: "Pergola",
      image: "public_v2/hero-pergola-closeup-cgi.png",
      alt: "Pergola bioclimatique premium en gros plan vue de dessus sur fond blanc",
      kicker: "Pergola",
      title: "Ombre",
      accent_title: "precise",
      accent: "#00a7ff"
    },
    {
      key: "mosquito-screen",
      label: "Moustiquaire",
      image: "public_v2/hero-mosquito-screen-closeup-cgi.png",
      alt: "Moustiquaire premium en gros plan vue de face sur fond blanc",
      kicker: "Moustiquaire",
      title: "Air frais",
      accent_title: "protege",
      accent: "#34c759"
    },
    {
      key: "awning-box",
      label: "Store coffre",
      image: "public_v2/hero-awning-box-closeup-cgi.png",
      alt: "Store banne coffre premium en gros plan vue de dessus sur fond blanc",
      kicker: "Store coffre",
      title: "Terrasse",
      accent_title: "ombragee",
      accent: "#ff9f0a"
    }
  ].freeze
  HERO_PRODUCT_INITIAL_KEY = "awning-box"
  HERO_FACT_ITEMS = [
    {
      variant: :accent,
      value: "48h",
      text: "Premier retour"
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

  def initialize(home_page:, debug: false)
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :home_page

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
      "grid w-full min-w-0 gap-4",
      debug_class
    )
  end
end
