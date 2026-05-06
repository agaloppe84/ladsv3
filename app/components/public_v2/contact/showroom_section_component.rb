# frozen_string_literal: true

class PublicV2::Contact::ShowroomSectionComponent < ViewComponent::Base
  SHOWROOM_POINTS = [
    "Comparer les familles produits et les niveaux de finition.",
    "Voir les materiaux, les coloris et les mecanismes.",
    "Preparer une demande de devis avec les bonnes informations."
  ].freeze

  private

  def showroom_points
    SHOWROOM_POINTS
  end
end
