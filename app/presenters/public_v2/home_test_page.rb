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

  COMPOSITIONS = [
    Composition.new(
      code: "H01",
      name: "Command center",
      intent: "Design + devis clair",
      strategy: "Hero compact, preuves courtes, photo en vignette.",
      pattern: :compact_command,
      image: "magasin-04.jpeg",
      image_alt: "Showroom Les Artisans du Store avec stores et finitions exposees",
      kicker: "Showroom · projet · devis",
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
      kicker: "L'Arbresle · Rhone",
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

  def compositions
    COMPOSITIONS
  end
end
