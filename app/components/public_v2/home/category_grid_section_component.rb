# frozen_string_literal: true

class PublicV2::Home::CategoryGridSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  CATEGORY_CONTENT = {
    "moustiquaires" => {
      eyebrow: "PROTECTION INVISIBLE",
      title: "Moustiquaires",
      title_suffix: "aérez tranquille",
      text: "Une toile fine pour profiter de l’air frais. Elle protège sans alourdir vos ouvertures.",
      accent: "#008F86",
      size: :wide
    },
    "pergolas" => {
      eyebrow: "CONFORT EXTÉRIEUR",
      title: "Pergolas",
      title_suffix: "vivez dehors",
      text: "Ombre maîtrisée, confort et lignes épurées. Votre terrasse devient un vrai espace de vie.",
      accent: "#C98646",
      size: :md
    },
    "portes-de-garage" => {
      eyebrow: "ACCÈS SÉCURISÉ",
      title: "Portes de garage",
      title_suffix: "sécurisez l’accès",
      text: "Des panneaux robustes et une ouverture fluide. Une finition moderne pour votre façade.",
      accent: "#5B718F",
      size: :wide
    },
    "stores-exterieurs" => {
      eyebrow: "OMBRE & TERRASSE",
      title: "Stores extérieurs",
      title_suffix: "maîtrisez le soleil",
      text: "Store banne, toile technique et ombre élégante. Prolongez les beaux jours sur la terrasse.",
      accent: "#E57919",
      size: :wide
    },
    "stores-interieurs" => {
      eyebrow: "LUMIÈRE SUR MESURE",
      title: "Stores intérieurs",
      title_suffix: "dosez la lumière",
      text: "Vénitiens, enrouleurs, plissés ou voilages. Chaque pièce trouve son équilibre.",
      accent: "#E94F6A",
      size: :md
    },
    "volets-battants" => {
      eyebrow: "CHARME & DURABILITÉ",
      title: "Volets battants",
      title_suffix: "gardez le caractère",
      text: "Des battants résistants et personnalisables. Le style de la maison, sans compromis.",
      accent: "#4F9A63",
      size: :compact
    },
    "volets-roulants" => {
      eyebrow: "ISOLATION & SÉCURITÉ",
      title: "Volets roulants",
      title_suffix: "gagnez en confort",
      text: "Un tablier compact, motorisable et protecteur. Plus de confort, toute l’année.",
      accent: "#7468F0",
      size: :md
    },
    "pergostores" => {
      eyebrow: "OMBRE TECHNIQUE",
      title: "Pergostores",
      title_suffix: "modulez l’abri",
      text: "Une solution hybride pour terrasse exposée. Le confort d’un store avec une tenue plus structurée.",
      accent: "#B8773E",
      size: :compact
    }
  }.freeze

  FALLBACK_CONTENT = {
    eyebrow: "SOLUTION SUR MESURE",
    title_suffix: "à cadrer ensemble",
    accent: "#ff3d12",
    size: :md
  }.freeze

  def initialize(category_cards:, debug: false)
    @category_cards = category_cards
    @debug = debug
  end

  private

  attr_reader :category_cards

  def category_feature_cards
    category_cards.map do |card|
      content = category_content_for(card)

      PublicV2::Ui::CategoryFeatureCardComponent.new(
        eyebrow: content[:eyebrow],
        title: content[:title],
        title_suffix: content[:title_suffix],
        text: content[:text],
        accent: content[:accent],
        size: content[:size],
        path: helpers.public_v2_categories_path(anchor: "categorie-#{card.category.id}"),
        aria_label: "Voir #{card.category.name}",
        debug: debug?
      )
    end
  end

  def category_content_for(card)
    category = card.category
    content = CATEGORY_CONTENT.fetch(category.name.to_s.parameterize, {})
    fallback_title = category.name.to_s

    FALLBACK_CONTENT.merge(
      title: fallback_title,
      text: card.description
    ).merge(content)
  end

  def initial_category_index
    return 0 if category_cards.size <= 1

    [3, category_cards.size - 1].min
  end

  def component_classes
    component_class_names(
      "pv2-home-section pv2-home-warm__catalog",
      "grid w-full min-w-0 gap-5",
      debug_class
    )
  end
end
