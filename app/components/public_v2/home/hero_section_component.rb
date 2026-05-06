# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  SUPPORT_PANELS = [
    {
      kicker: "Conseil",
      title: "Showroom",
      text: "Besoin, dimensions et contraintes."
    },
    {
      kicker: "Selection",
      title: "Sur mesure",
      text: "Confort, protection et tenue."
    },
    {
      kicker: "Pose",
      title: "Equipe terrain",
      text: "Fourniture et installation locale."
    },
    {
      kicker: "SAV",
      title: "Suivi local",
      text: "Accompagnement apres la pose."
    }
  ].freeze

  def initialize(home_page:, debug: false)
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :home_page

  def featured_alt
    home_page.featured_product&.name || "Showroom Les Artisans du Store"
  end

  def support_panels
    SUPPORT_PANELS
  end

  def component_classes
    [
      "pv2-home-graphite__hero",
      "grid w-full min-w-0 gap-4",
      debug_class
    ].compact.join(" ")
  end
end
