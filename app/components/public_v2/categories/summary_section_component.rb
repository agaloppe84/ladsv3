# frozen_string_literal: true

class PublicV2::Categories::SummarySectionComponent < ViewComponent::Base
  STATS = [
    ["Showroom", "200m2", "Voir les mecanismes, les toiles et les finitions avant de choisir."],
    ["Devis", "48h", "Premier retour pour cadrer produit, dimensions et contraintes."],
    ["Pose", "35 ans", "Experience terrain, prise de cotes, installation et SAV."]
  ].freeze

  private

  def stats
    STATS
  end
end
