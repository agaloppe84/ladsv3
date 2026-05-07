# frozen_string_literal: true

class PublicV2::Contact::ShowroomSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  SHOWROOM_POINTS = [
    "Comparer les familles produits et les niveaux de finition.",
    "Voir les materiaux, les coloris et les mecanismes.",
    "Preparer une demande de devis avec les bonnes informations."
  ].freeze

  private

  def showroom_points
    SHOWROOM_POINTS
  end

  def component_classes
    [
      "pv2-contact-showroom",
      "grid w-full min-w-0 grid-cols-1 items-center gap-4 p-4 min-[1121px]:grid-cols-[minmax(360px,.72fr)_minmax(0,1fr)]",
      debug_class
    ].compact.join(" ")
  end
end
