# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  SUPPORT_PANELS = [
    {
      kicker: "Devis",
      title: "Retour 48h",
      text: "Un premier cadrage pour avancer vite.",
      variant: :flashy
    },
    {
      kicker: "Metier",
      title: "Lecture terrain",
      text: "Exposition, dimensions, usage et contraintes.",
      variant: :outline
    },
    {
      kicker: "Pose",
      title: "Equipe locale",
      text: "Conseil, installation et suivi SAV.",
      variant: :soft
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

  def hero_image
    home_page.featured_image || "magasin-01.jpeg"
  end

  def proof_items
    home_page.hero_proof_items
  end

  def component_classes
    component_class_names(
      "pv2-home-warm__hero pv2-home-hero-v2",
      "grid w-full min-w-0 gap-4",
      debug_class
    )
  end
end
