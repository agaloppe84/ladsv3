# frozen_string_literal: true

class PublicV2::Home::ExpertiseSectionComponent < ViewComponent::Base
  TRACKS = [
    ["01", "Se proteger du soleil", "Stores bannes, screens, pergolas, toiles et solutions pour gerer chaleur et luminosite."],
    ["02", "Fermer et securiser", "Volets roulants, volets battants, portes de garage et motorisations adaptees au quotidien."],
    ["03", "Gagner en confort", "Moustiquaires, stores interieurs, SAV et conseils pour les contraintes de pose."]
  ].freeze

  private

  def tracks
    TRACKS
  end
end
