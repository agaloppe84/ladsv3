# frozen_string_literal: true

class PublicV2::Content::RecommendationsComponent < ViewComponent::Base
  include PublicV2::Debuggable

  DEFAULT_REVIEWS = [
    {
      quote: "Très sympa, ponctuel et efficace ! Je pensais que le chantier serait bien plus complexe. Je recommande vivement.",
      author: "Aurélie et Yann"
    },
    {
      quote: "Réactivité, disponibilité et service après-vente impeccables sur la pose de moustiquaires arrivées en fin de garantie. Contrôle des moustiquaires et travail très soigné.",
      author: "Françoise B"
    },
    {
      quote: "Entreprise honnête et efficace que je recommande vivement",
      author: "christiane de bellefon"
    },
    {
      quote: "Merci Les artisans du store pour l'installation de nos moustiquaires ! Tout s'est très bien passé, bravo à vous !",
      author: "Fanny Best"
    }
  ].freeze
  GOOGLE_REVIEWS_URL = "https://www.google.com/maps/search/?api=1&query=Les%20Artisans%20du%20Store%2C%2035%20Rue%20des%20Martinets%2069210%20L%27Arbresle"

  def initialize(reviews: DEFAULT_REVIEWS, reviews_url: GOOGLE_REVIEWS_URL, classes: nil, debug: false)
    @reviews = reviews
    @reviews_url = reviews_url
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :reviews, :reviews_url, :classes

  def component_classes
    component_class_names("pv2-recommendations", "grid w-full min-w-0 gap-6", debug_class, classes)
  end
end
