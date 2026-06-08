# frozen_string_literal: true

class PublicV2::Content::PartnersComponent < ViewComponent::Base
  include PublicV2::Debuggable

  DEFAULT_PARTNERS = [
    { name: "Somfy", logo: "somfy.svg" },
    { name: "Luxaflex", logo: "logo-luxaflex.svg" },
    { name: "Coublanc", logo: "coublanc_2.svg" },
    { name: "Matest", logo: "logo-Matest.svg" },
    { name: "France Fermeture", logo: "logo-France-Fermeture.svg" },
    { name: "Reflexsol", logo: "logo-REFLEXSOL.svg" },
    { name: "Dickson", logo: "logo-dickson.svg" },
    { name: "Sommer", logo: "Logo-Sommer.svg" },
    { name: "Serge Ferrari", logo: "Logo Serge Ferrari.svg" },
    { name: "Sattler", logo: "Logo Sattler Black.svg" }
  ].freeze

  def initialize(
    title: "Nos partenaires",
    text: "Des fabricants retenus pour la fiabilite des moteurs, des toiles, des fermetures et des finitions visibles au showroom.",
    partners: DEFAULT_PARTNERS,
    classes: nil,
    debug: false
  )
    @title = title
    @text = text
    @partners = partners
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :title, :text, :partners, :classes

  def component_classes
    component_class_names("pv2-partners", "grid w-full min-w-0 gap-6", debug_class, classes)
  end
end
