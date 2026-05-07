# frozen_string_literal: true

class PublicV2::Home::ExpertiseSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  TRACKS = [
    ["01", "Se proteger du soleil", "Stores bannes, screens, pergolas, toiles et solutions pour gerer chaleur et luminosite."],
    ["02", "Fermer et securiser", "Volets roulants, volets battants, portes de garage et motorisations adaptees au quotidien."],
    ["03", "Gagner en confort", "Moustiquaires, stores interieurs, SAV et conseils pour les contraintes de pose."]
  ].freeze

  def initialize(debug: false)
    @debug = debug
  end

  private

  def tracks
    TRACKS
  end

  def component_classes
    [
      "pv2-home-section pv2-home-warm__matrix",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
