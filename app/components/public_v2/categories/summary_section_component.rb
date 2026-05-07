# frozen_string_literal: true

class PublicV2::Categories::SummarySectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  STATS = [
    ["Showroom", "200m2", "Voir les mecanismes, les toiles et les finitions avant de choisir."],
    ["Devis", "48h", "Premier retour pour cadrer produit, dimensions et contraintes."],
    ["Pose", "35 ans", "Experience terrain, prise de cotes, installation et SAV."]
  ].freeze

  private

  def stats
    STATS
  end

  def component_classes
    [
      "pv2-public-index__summary",
      "grid w-full min-w-0 grid-cols-1 gap-3 min-[821px]:grid-cols-3",
      debug_class
    ].compact.join(" ")
  end
end
