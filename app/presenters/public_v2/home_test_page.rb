# frozen_string_literal: true

class PublicV2::HomeTestPage
  Composition = Struct.new(
    :code,
    :name,
    :intent,
    :strategy,
    :pattern,
    :image,
    :image_alt,
    :kicker,
    :title,
    :text,
    :layout_codes,
    :variant_labels,
    :facts,
    :panels,
    keyword_init: true
  )

  FullComposition = Struct.new(
    :code,
    :name,
    :intent,
    :strategy,
    :pattern,
    :hero_title,
    :hero_text,
    :accent,
    :media_level,
    :quote_pressure,
    :layout_codes,
    :bricks,
    :section_order,
    keyword_init: true
  )

  RECIPE_DETAILS = {
    compact_command: {
      global: "Command center compact",
      section: "Hero texte + support media",
      micro: "Proof rail + CTA dock",
      bricks: ["Spotlight flashy", "ProofRail", "ActionDock", "MediaFrame"],
      accent: "Fort mais contenu",
      media: "Photo secondaire",
      quote: "Directe"
    },
    quote_dock: {
      global: "Dock devis lateral",
      section: "Texte principal + colonne preuves",
      micro: "Action dock + stats compactes",
      bricks: ["ActionDock", "ProofRail", "Panel outline", "MediaFrame"],
      accent: "Moyen",
      media: "Photo preuve courte",
      quote: "Tres visible"
    },
    soft_bento: {
      global: "Bento premium clair",
      section: "Promesse + modules courts",
      micro: "Choice tiles + accent compact",
      bricks: ["ChoiceTile", "Panel soft", "Panel flashy", "MediaFrame"],
      accent: "Faible avec pic flashy",
      media: "Module image",
      quote: "Visible"
    },
    selection_board: {
      global: "Board de selection",
      section: "Choix produit avant CTA",
      micro: "Tiles decisionnelles",
      bricks: ["ChoiceTile", "ActionDock", "MediaFrame"],
      accent: "Moyen",
      media: "Bande support",
      quote: "Apres choix"
    },
    studio_notes: {
      global: "Studio notes",
      section: "Conseil + notes projet",
      micro: "Step rail editorial",
      bricks: ["StepRail", "Panel outline", "Panel flashy", "MediaFrame"],
      accent: "Faible",
      media: "Timbre image",
      quote: "Douce"
    },
    conversion_rail: {
      global: "Rail de conversion",
      section: "Parcours devis en 3 blocs",
      micro: "Step rail vertical + action dock",
      bricks: ["StepRail", "ActionDock", "MediaFrame"],
      accent: "Fort controle",
      media: "Photo en bas de rail",
      quote: "Prioritaire"
    },
    proof_stack: {
      global: "Stack confiance",
      section: "Preuves locales avant action",
      micro: "Proof cluster + CTA compact",
      bricks: ["ProofRail", "Panel flashy", "MediaFrame"],
      accent: "Faible avec CTA vert",
      media: "Mini photo locale",
      quote: "Rassurante"
    },
    modular_catalog: {
      global: "Catalogue modulaire",
      section: "Familles produit + demande",
      micro: "Choice tiles + dock secondaire",
      bricks: ["ChoiceTile", "ActionDock", "MediaFrame"],
      accent: "Moyen",
      media: "Vignette catalogue",
      quote: "Contextuelle"
    },
    graphite_desk: {
      global: "Desk graphite",
      section: "Ambiance atelier sombre",
      micro: "Cartes techniques + dock devis",
      bricks: ["Dark cards", "ActionDock", "MediaFrame"],
      accent: "Fin et premium",
      media: "Detail matiere",
      quote: "Nette"
    },
    calm_intake: {
      global: "Intake calme",
      section: "Demande guidee sans formulaire lourd",
      micro: "Step rail compact + action dock",
      bricks: ["StepRail", "ActionDock", "Panel outline", "MediaFrame"],
      accent: "Doux",
      media: "Image discrete",
      quote: "Progressive"
    }
  }.freeze

  COMPOSITIONS = [
    Composition.new(
      code: "H01",
      name: "Command center",
      intent: "Design + devis clair",
      strategy: "Hero compact, preuves courtes, photo en vignette.",
      pattern: :compact_command,
      image: "magasin-04.jpeg",
      image_alt: "Showroom Les Artisans du Store avec stores et finitions exposees",
      kicker: "Showroom - projet - devis",
      title: "Cadrez vite. Chiffrez juste.",
      text: "Une home qui ressemble a un poste de pilotage simple.",
      layout_codes: %w[G46 S49 S60],
      variant_labels: ["Photo secondaire", "Flashy compact", "Dashboard calme"],
      facts: [
        { value: "48h", label: "Retour" },
        { value: "3", label: "Etapes" },
        { value: "1", label: "Equipe" }
      ],
      panels: [
        { kicker: "01", title: "Besoin", text: "Store, volet, pergola." },
        { kicker: "02", title: "Contexte", text: "Photo ou dimensions." },
        { kicker: "03", title: "Suite", text: "Retour clair." }
      ]
    ),
    Composition.new(
      code: "H02",
      name: "Quote dock",
      intent: "Devis visible + moderne",
      strategy: "Bloc devis type dock, photo petite, lecture tres directe.",
      pattern: :quote_dock,
      image: "magasin-01.jpeg",
      image_alt: "Facade et vehicules Les Artisans du Store",
      kicker: "Devis sans detour",
      title: "Une demande courte. Un retour utile.",
      text: "Le CTA reste proche, sans prendre toute la page.",
      layout_codes: %w[G29 S64 S10],
      variant_labels: ["Dock CTA", "Texte court", "Photo preuve"],
      facts: [
        { value: "35 ans", label: "Metier" },
        { value: "Rhone", label: "Local" },
        { value: "SAV", label: "Suivi" }
      ],
      panels: [
        { kicker: "Type", title: "Projet", text: "Famille produit." },
        { kicker: "Lieu", title: "Adresse", text: "Zone de pose." },
        { kicker: "Retour", title: "Rappel", text: "Cadre rapide." }
      ]
    ),
    Composition.new(
      code: "H03",
      name: "Soft bento",
      intent: "Premium doux + devis",
      strategy: "Bento clair, accent petit, photo dans un seul module.",
      pattern: :soft_bento,
      image: "magasin-02.jpeg",
      image_alt: "Panneaux de stores et finitions en showroom",
      kicker: "Choix guide",
      title: "Le bon produit, sans surcharge.",
      text: "Un bento calme pour guider avant le devis.",
      layout_codes: %w[G09 S48 S43],
      variant_labels: ["Bento light", "Accent controle", "Photo module"],
      facts: [
        { value: "01", label: "Choisir" },
        { value: "02", label: "Cadrer" },
        { value: "03", label: "Devis" }
      ],
      panels: [
        { kicker: "Stores", title: "Solaire", text: "Terrasse et baie." },
        { kicker: "Volets", title: "Fermeture", text: "Confort." },
        { kicker: "Pergolas", title: "Exterieur", text: "Ombre durable." }
      ]
    ),
    Composition.new(
      code: "H04",
      name: "Selection board",
      intent: "Produits + devis",
      strategy: "Entrees produit en premier, photo fine, CTA apres choix.",
      pattern: :selection_board,
      image: "magasin-06.jpeg",
      image_alt: "Echantillons de tissus et matieres de stores",
      kicker: "Selection rapide",
      title: "Choisir le sujet du devis.",
      text: "La home commence par le besoin, pas par une grande image.",
      layout_codes: %w[G14 S11 S18],
      variant_labels: ["Produit first", "Photo fine", "Decision rapide"],
      facts: [
        { value: "Store", label: "Ombre" },
        { value: "Volet", label: "Fermeture" },
        { value: "Porte", label: "Garage" }
      ],
      panels: [
        { kicker: "01", title: "Ombre", text: "Store ou pergola." },
        { kicker: "02", title: "Fermeture", text: "Volet ou porte." },
        { kicker: "03", title: "Confort", text: "Moustiquaire." }
      ]
    ),
    Composition.new(
      code: "H05",
      name: "Studio notes",
      intent: "Conseil premium",
      strategy: "Ambiance studio : notes, preuves, photo tres contenue.",
      pattern: :studio_notes,
      image: "magasin-03.jpeg",
      image_alt: "Facade Les Artisans du Store et vehicules de pose",
      kicker: "Conseil local",
      title: "Un projet mieux prepare.",
      text: "Le devis devient une suite naturelle du conseil.",
      layout_codes: %w[G18 S73 S51],
      variant_labels: ["Studio", "Notes projet", "Photo timbre"],
      facts: [
        { value: "RGE", label: "Signal" },
        { value: "Pose", label: "Terrain" },
        { value: "Local", label: "Equipe" }
      ],
      panels: [
        { kicker: "Note", title: "Usage", text: "Soleil, securite, confort." },
        { kicker: "Note", title: "Budget", text: "Fourchette utile." },
        { kicker: "Note", title: "Timing", text: "Souhait ou urgence." }
      ]
    ),
    Composition.new(
      code: "H06",
      name: "Conversion rail",
      intent: "Devis direct",
      strategy: "Rail d'action moderne, image discrete, aucun grand bloc.",
      pattern: :conversion_rail,
      image: "magasin-04.jpeg",
      image_alt: "Showroom Les Artisans du Store avec table conseil",
      kicker: "Parcours devis",
      title: "Trois infos. On vous rappelle.",
      text: "Le parcours est visible sans ressembler a un formulaire lourd.",
      layout_codes: %w[G13 S55 S49],
      variant_labels: ["Rail", "CTA clair", "Densite courte"],
      facts: [
        { value: "01", label: "Produit" },
        { value: "02", label: "Lieu" },
        { value: "03", label: "Contact" }
      ],
      panels: [
        { kicker: "Produit", title: "Famille", text: "Le sujet." },
        { kicker: "Lieu", title: "Pose", text: "La zone." },
        { kicker: "Contact", title: "Rappel", text: "La suite." }
      ]
    ),
    Composition.new(
      code: "H07",
      name: "Proof stack",
      intent: "Confiance design",
      strategy: "Preuves locales en pile, photo minime, devis visible.",
      pattern: :proof_stack,
      image: "magasin-01.jpeg",
      image_alt: "Facade et vehicules de pose Les Artisans du Store",
      kicker: "L'Arbresle - Rhone",
      title: "Du local, pas un tunnel anonyme.",
      text: "Une home plus humaine, mais toujours tres nette.",
      layout_codes: %w[G24 S50 S23],
      variant_labels: ["Preuve locale", "Photo mini", "Action proche"],
      facts: [
        { value: "04 74", label: "Direct" },
        { value: "35 ans", label: "Metier" },
        { value: "Pose", label: "Locale" }
      ],
      panels: [
        { kicker: "Direct", title: "Appel", text: "Un vrai contact." },
        { kicker: "Metier", title: "Conseil", text: "Avant le prix." },
        { kicker: "Suivi", title: "SAV", text: "Apres la pose." }
      ]
    ),
    Composition.new(
      code: "H08",
      name: "Modular catalog",
      intent: "Catalogue + devis",
      strategy: "Catalogue tres graphique, photo comme repere seulement.",
      pattern: :modular_catalog,
      image: "magasin-02.jpeg",
      image_alt: "Echantillons et stores exposes en showroom",
      kicker: "Familles produit",
      title: "La bonne entree pour le bon devis.",
      text: "Une composition propre pour relier catalogue et demande.",
      layout_codes: %w[G22 S13 S49],
      variant_labels: ["Catalogue moderne", "Micro photo", "CTA contenu"],
      facts: [
        { value: "Store", label: "Solaire" },
        { value: "Volet", label: "Confort" },
        { value: "Pergola", label: "Exterieur" }
      ],
      panels: [
        { kicker: "A", title: "Stores", text: "Ombre." },
        { kicker: "B", title: "Volets", text: "Fermeture." },
        { kicker: "C", title: "Pergolas", text: "Terrasse." }
      ]
    ),
    Composition.new(
      code: "H09",
      name: "Graphite desk",
      intent: "Design sombre + devis",
      strategy: "Ambiance graphite, photo petite, accent devis tres maitrise.",
      pattern: :graphite_desk,
      image: "magasin-06.jpeg",
      image_alt: "Detail de tissus et matieres de stores",
      kicker: "Atelier devis",
      title: "Des choix nets. Un prix plus clair.",
      text: "Plus premium, plus calme, moins vitrine.",
      layout_codes: %w[G27 S51 S64],
      variant_labels: ["Graphite", "Photo detail", "Accent fin"],
      facts: [
        { value: "Toile", label: "Choix" },
        { value: "Option", label: "Details" },
        { value: "Prix", label: "Cadrage" }
      ],
      panels: [
        { kicker: "01", title: "Comparer", text: "Finitions." },
        { kicker: "02", title: "Verifier", text: "Mesures." },
        { kicker: "03", title: "Chiffrer", text: "Devis." }
      ]
    ),
    Composition.new(
      code: "H10",
      name: "Calm intake",
      intent: "Devis doux + moderne",
      strategy: "Micro formulaire visuel, photo discrete, friction minimale.",
      pattern: :calm_intake,
      image: "magasin-04.jpeg",
      image_alt: "Showroom Les Artisans du Store avec produits exposes",
      kicker: "Demande simple",
      title: "Commencer sans se tromper.",
      text: "La page transforme le devis en premier cadrage rassurant.",
      layout_codes: %w[G40 S10 S60],
      variant_labels: ["Micro form", "Photo discrete", "Tres lisible"],
      facts: [
        { value: "Besoin", label: "Une phrase" },
        { value: "Photo", label: "Optionnelle" },
        { value: "Contact", label: "Rappel" }
      ],
      panels: [
        { kicker: "01", title: "Votre besoin", text: "Court." },
        { kicker: "02", title: "Votre lieu", text: "Local." },
        { kicker: "03", title: "Votre retour", text: "48h." }
      ]
    )
  ].freeze

  FULL_COMPOSITIONS = [
    FullComposition.new(
      code: "F01",
      name: "Devis studio compact",
      intent: "Premium sobre + devis rapide",
      strategy: "La page met le cadrage devis au centre, avec une photo courte et des preuves proches de l'action.",
      pattern: :quote_studio,
      hero_title: "Un projet bien cadre. Un devis plus clair.",
      hero_text: "Besoin, contexte, retour. La home avance comme un premier rendez-vous.",
      accent: "Fort mais compact",
      media_level: "Photo courte",
      quote_pressure: "Prioritaire",
      layout_codes: %w[G29 S49 M18],
      bricks: ["SummaryBox", "QuoteIntake", "TrustCluster", "ProductFamilyGrid", "ActionDock"],
      section_order: ["Hero devis", "Preuves", "Besoins", "Familles", "Showroom", "CTA final"]
    ),
    FullComposition.new(
      code: "F02",
      name: "Showroom editorial",
      intent: "Design magazine + choix rassure",
      strategy: "La page installe une ambiance plus premium, puis transforme le showroom en preuve et en aide au devis.",
      pattern: :showroom_editorial,
      hero_title: "Voir, choisir, chiffrer sans flou.",
      hero_text: "Une home plus visuelle, mais la photo reste un repere de confiance.",
      accent: "Moyen",
      media_level: "Mosaic controlee",
      quote_pressure: "Visible",
      layout_codes: %w[G18 S73 M33],
      bricks: ["MediaMosaic", "Panel flashy", "ComparisonStrip", "ProcessList", "QuoteIntake"],
      section_order: ["Hero editorial", "Showroom", "Comparaison", "Produits", "Parcours", "CTA final"]
    ),
    FullComposition.new(
      code: "F03",
      name: "Concierge produit",
      intent: "Guidage client + demande courte",
      strategy: "La page commence par le besoin client, puis relie produit, conseil, pose et devis sans tunnel lourd.",
      pattern: :choice_concierge,
      hero_title: "Choisir le bon point de depart.",
      hero_text: "Stores, volets, pergolas ou confort quotidien : chaque entree mene vers un devis plus utile.",
      accent: "Faible avec pics",
      media_level: "Photo en support",
      quote_pressure: "Progressive",
      layout_codes: %w[G14 S11 M42],
      bricks: ["ChoiceTile", "IconList", "ProcessList", "FaqAccordion", "ActionDock"],
      section_order: ["Choix besoin", "Familles", "Preuves", "Pose", "Objections", "CTA final"]
    )
  ].freeze

  def compositions
    COMPOSITIONS
  end

  def full_compositions
    FULL_COMPOSITIONS
  end

  def blueprint
    @blueprint ||= PublicV2::HomeContentBlueprint.new
  end

  def recipe_for(composition)
    RECIPE_DETAILS.fetch(composition.pattern)
  end

  def recipe_rows(composition)
    recipe = recipe_for(composition)

    [
      ["Layout global", recipe.fetch(:global)],
      ["Layout section", recipe.fetch(:section)],
      ["Micro-layout", recipe.fetch(:micro)],
      ["Accent", recipe.fetch(:accent)],
      ["Photo", recipe.fetch(:media)],
      ["Pression devis", recipe.fetch(:quote)]
    ]
  end

  def recipe_bricks(composition)
    recipe_for(composition).fetch(:bricks)
  end

  def full_recipe_rows(composition)
    [
      ["Layout global", composition.intent],
      ["Layout section", composition.strategy],
      ["Accent", composition.accent],
      ["Photo", composition.media_level],
      ["Pression devis", composition.quote_pressure],
      ["Ordre", composition.section_order.join(" -> ")]
    ]
  end
end
