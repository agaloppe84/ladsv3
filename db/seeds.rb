# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Category.destroy_all
Product.destroy_all
Option.destroy_all
Brand.destroy_all
Motorist.destroy_all
Ral.destroy_all
Event.destroy_all





coublanc_brand = Brand.create!(name: 'Coublanc', logo: 'coublanc')
matest_brand = Brand.create!(name: 'Matest', logo: 'matest')

somfy_motorist = Motorist.create!(name: 'Somfy', logo: 'somfy')
wellcom_motorist = Motorist.create!(name: "Well'Com", logo: 'wellcom')

# ------ Create Rals -------
rals = RalCsvParser.new("ral_refs")
rals.process_file

# ------------ Create Event -------------
event = Event.create(title: "PORTES OUVERTES", content: "-20% sur tous les produits complets, posés par nos soins.
le vendredi 22 et le samedi 23 mars 2024 de 9h00 à 18h30", start_date: DateTime.now, end_date: DateTime.now + 2.days)

# Définir les catégories et produits
categories_data = [
  {
    name: "Stores extérieurs",
    products: [
      {
        name: "Store coffre",
        description: "Design et robuste, le store coffre intégral offre une protection solaire efficace et esthétique.",
        options: [
          "Armature en aluminium extrudé thermolaqué (blanc, ivoire ou gris anthracite - 216 RAL en option)",
          "Bras en aluminium à sangle Rubonium® ou à câbles gainés",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 12m",
          "Avancée jusqu’à 4m",
          "Toile acrylique teint masse 290g/m² (270 couleurs unies ou à rayures)",
          "Lambrequin droit ou à vagues",
          "Options : éclairage Leds, paresoleil, automatismes (vent, soleil, domotique)"
        ]
      },
      {
        name: "Store monobloc",
        description: "Réalisable dans de très grandes dimensions, la conception du monobloc avec tube porteur fait de ce store un modèle extrêmement fiable.",
        options: [
          "Armature en aluminium première fusion thermolaqué (90 coloris)",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 18m",
          "Avancée jusqu’à 4m",
          "Toile acrylique teint masse 290g/m² (270 couleurs unies ou à rayures)",
          "Lambrequin droit ou à vagues",
          "Options : auvent de protection, éclairage Leds, paresoleil, automatismes (vent, soleil, domotique)"
        ]
      },
      {
        name: "Store loggia",
        description: "Adapté aux balcons, le store Loggia est le seul modèle qui peut être fixé latéralement, entre deux murs. Avec une inclinaison possible jusqu’à 85°, il permet une occultation presque totale de la fenêtre.",
        options: [
          "Armature en aluminium première fusion thermolaqué (90 coloris)",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 5,55m",
          "Avancée jusqu’à 2,5m",
          "Toile acrylique teint masse (270 couleurs unies ou à rayures)",
          "Lambrequin droit ou à vagues",
          "Options : auvent de protection, éclairage Leds, paresoleil, automatismes (vent, soleil, domotique)"
        ]
      },
      {
        name: "Store bannette",
        description: "A projection ou à conducteur vertical, le store bannette est spécialement conçu pour la protection des fenêtres. Selon la toile que vous choisirez, vous maîtriserez en douceur la lumière pour un meilleur confort thermique et visuel.",
        options: [
          "Armature en aluminium première fusion thermolaqué (90 coloris)",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 4m",
          "Avancée jusqu’à 1,2m (à projection)",
          "Hauteur jusqu’à 3m (à conducteur)",
          "Toile acrylique teint masse ou polyester (232 couleurs)",
          "Options : auvent de protection, joues"
        ]
      },
      {
        name: "Store vertical",
        description: "Le store coffre vertical est conçu pour vous protéger efficacement du soleil, du vent et du vis-à-vis.",
        options: [
          "Profils en aluminium extrudé thermolaqué (blanc ou gris anthracite - 216 RAL en option)",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 6m",
          "Surface maximum de 15m2",
          "Toile PVC"
        ]
      },
      {
        name: "Abri 2 pentes",
        description: "L’abri 2 pentes est très apprécié pour sa simplicité d’utilisation et son confort déjà reconnu sur les terrasses.",
        options: [
          "Armature en aluminium première fusion thermolaqué (90 coloris)",
          "Bras en aluminium à câbles gainés",
          "Manoeuvre manuelle ou motorisation Somfy®",
          "Largeur jusqu’à 18m",
          "Avancée jusqu’à 4m par côté",
          "Montants cylindriques (Ø 80mm)",
          "Toile acrylique teint masse (270 couleurs unies ou à rayures)",
          "Lambrequin droit ou à vagues",
          "Options : auvent de protection, éclairage Leds, paresoleil, automatismes (vent, soleil)"
        ]
      }
    ]
  },
  {
    name: "Pergostores",
    products: [
      {
        name: "Pergostore Lacharme",
        description: "Une protection solaire innovante et élégante pour vos terrasses et balcons.",
        options: [
          "Profils en aluminium extrudé thermolaqué (blanc ou gris anthracite - 216 RAL en option)",
          "Fixation murale + 2 pieds à l’avant",
          "Récupération des eaux pluviales",
          "Largeur jusqu’à 6m",
          "Avancée jusqu’à 5m",
          "Toile acrylique XXL (19 coloris)",
          "Options : fermetures périphériques, éclairage Leds, chauffage, automatismes (vent, soleil)"
        ]
      }
    ]
  },
  {
    name: "Pergolas",
    products: [
      {
        name: "Pergola bioclimatique",
        description: "Les lames motorisées des pergolas bioclimatiques permettent une orientation jusqu’à 150° pour un confort optimal.",
        options: [
          "Profils en aluminium extrudé thermolaqué (blanc ou gris anthracite - 216 RAL en option)",
          "Fixation murale ou autoportante",
          "Récupération des eaux pluviales",
          "Largeur jusqu’à 7m",
          "Avancée jusqu’à 5m",
          "Options : fermetures périphériques, éclairage Leds, chauffage, automatismes (vent, soleil)"
        ]
      },
      {
        name: "Pergola toile",
        description: "Cette pergola vous protègera du soleil et de la pluie grâce à sa toile technique rétractable.",
        options: [
          "Profils en aluminium extrudé thermolaqué (blanc ou gris anthracite - 216 RAL en option)",
          "Fixation murale ou autoportante",
          "Récupération des eaux pluviales",
          "Largeur jusqu’à 7m",
          "Avancée jusqu’à 5m",
          "Toile composite (8 coloris + 6 coloris en option)",
          "Options : fermetures périphériques, éclairage Leds, chauffage, automatismes (vent, soleil)"
        ]
      }
    ]
  },
  {
    name: "Stores intérieurs",
    products: [
      {
        name: "Store rouleau",
        description: "Des magnifiques tissus pour obscurcir une pièce ou filtrer la lumière au contrôle intelligent.",
        options: [
          "Fenêtre oscillo-battante, fenêtre de toit, baie vitrée",
          "Manoeuvre à chaînette / cordon sans fin, LiteRise®, SoftRaise® ou motorisation PowerView®",
          "Tissu transparent, semi-transparent, obscurssissant ou occultant (234 coloris)"
        ]
      },
      {
        name: "Store rouleau LightLine®",
        description: "Les stores Luxaflex LightLine® diffusent une lumière douce uniformément dans la pièce.",
        options: [
          "Fenêtre oscillo-battante, baie vitrée",
          "Manoeuvre à chaînette / cordon sans fin ou motorisation PowerView®",
          "Tissu obscurssissant (234 coloris)"
        ]
      },
      {
        name: "Store rouleau Twist®",
        description: "Version innovante des stores enrouleurs classiques, conçu avec deux couches de tissu alternant transparence et opacité.",
        options: [
          "Fenêtre oscillo-battante, baie vitrée",
          "Manoeuvre à chaînette / cordon sans fin ou motorisation PowerView®",
          "Tissu : 120 coloris"
        ]
      },
      {
        name: "Store californien",
        description: "Les stores californiens offrent une flexibilité optimale pour les grandes fenêtres et les portes-fenêtres.",
        options: [
          "Baie vitrée, fenêtre de forme spéciale, grande fenêtre",
          "Manoeuvre à chaînette / cordon sans fin, tige / manivelle ou PowerView® automation",
          "Lames en tissu, PVC ou aluminium recyclé (52 à 127mm)"
        ]
      },
      {
        name: "Store Duette®",
        description: "Le design unique des stores Duette® crée une barrière isolante au niveau de vos fenêtres pour réguler la température.",
        options: [
          "Fenêtre oscillo-battante, fenêtre de toit, fenêtre ronde, fenêtre de forme spéciale, baie vitrée, grande fenêtre, porte coulissante, véranda",
          "Manoeuvre LiteRise®, SmartCord® ou motorisation PowerView®",
          "Tissu transparent, tamisant ou occultant (231 coloris)"
        ]
      },
      {
        name: "Store plissé",
        description: "Les stores plissés sont compatibles avec de nombreux modèles de fenêtres et apportent du caractère à votre séjour.",
        options: [
          "Fenêtre oscillo-battante, fenêtre de toit, fenêtre ronde, forme spéciale, baie vitrée, porte coulissante, véranda",
          "Manoeuvre à chaînette / cordon sans fin, LiteRise®, SmartCord® ou motorisation PowerView®",
          "Tissu transparent, semi-transparent, tamisant ou occultant (207 coloris)"
        ]
      },
      {
        name: "Store textile",
        description: "En associant innovation et confection traditionnelle, les stores textiles valorisent la beauté des tissus.",
        options: [
          "Fenêtre oscillo-battante, baie vitrée, porte coulissante",
          "Manoeuvre SmartCord® ou motorisation PowerView®",
          "Tissu transparent, semi-transparent, translucide ou occultant (2 coloris)"
        ]
      },
      {
        name: "Store vénitien",
        description: "Les stores vénitiens offrent une gestion flexible de la luminosité avec style et confort.",
        options: [
          "Fenêtre oscillo-battante, fenêtre de toit, fenêtre de forme spéciale, grande fenêtre",
          "Manoeuvre à chaînette / cordon sans fin, tige / manivelle, LiteRise® ou motorisation PowerView®",
          "Lames de 25, 50 ou 70mm (70 coloris)"
        ]
      },
      {
        name: "Store vénitien bois",
        description: "Fabriqués avec du bois dur certifié FSC®, ces stores vénitiens bois allient tradition et modernité.",
        options: [
          "Fenêtre oscillo-battante, grande fenêtre",
          "Manoeuvre à chaînette / cordon sans fin, tige / manivelle ou motorisation PowerView®",
          "Lames de 50 ou 70mm (70 coloris)"
        ]
      },
      {
        name: "Rideau",
        description: "Les rideaux donnent à chaque pièce une atmosphère chaleureuse et mettent en valeur les fenêtres.",
        options: [
          "Grande fenêtre",
          "Motorisation PowerView®",
          "Tissu transparent, semi-transparent, translucide ou occultant (2 coloris)"
        ]
      },
      {
        name: "Voile vénitien silhouette",
        description: "Composés de lamelles en tissu flottantes, les voiles vénitiens Silhouette® filtrent la lumière intense pour une ambiance douce.",
        options: [
          "Fenêtre oscillo-battante, grande fenêtre, baie vitrée",
          "Manoeuvre LiteRise®, SmartCord® ou motorisation PowerView®",
          "Tissu semi-transparent ou translucide (2 coloris)"
        ]
      }
    ]
  },
  {
    name: "Moustiquaires",
    products: [
      {
        name: "Moustiquaire enroulable verticale",
        description: "La moustiquaire à enroulement vertical garantit une protection contre la plupart des insectes.",
        options: [
          "Profils en aluminium thermolaqué (blanc, crème, gris anthracite ou noir - 216 RAL en option)",
          "Toile en fibre de verre enrobée de PVC (grise ou noire)",
          "Manoeuvre à tirage direct ou motorisée",
          "Options : toile Poll-Tex® (90 % du pollen filtré) ou toile Sunox (traitement anti-bactérien)"
        ]
      },
      {
        name: "Moustiquaire enroulable latérale",
        description: "Cette moustiquaire protège efficacement les portes et baies vitrées.",
        options: [
          "Profils en aluminium thermolaqué (blanc, crème, gris anthracite ou noir - 216 RAL en option)",
          "Toile en fibre de verre enrobée de PVC (gris ou noir)",
          "Manoeuvre à tirage direct",
          "Options : toile Poll-Tex® (90 % du pollen filtré) ou toile Sunox (traitement anti-bactérien)"
        ]
      },
      {
        name: "Moustiquaire plissée",
        description: "La solution compacte et esthétique pour se protéger des insectes tout en ventilant la maison.",
        options: [
          "Profils en aluminium thermolaqué (blanc, crème, gris anthracite ou noir - 216 RAL en option)",
          "Toile en fibre de verre enrobée de PVC (grise ou noire)",
          "Manoeuvre à tirage direct ou motorisée",
          "Options : toile Poll-Tex® (90 % du pollen filtré) ou toile Sunox (traitement anti-bactérien)"
        ]
      },
      {
        name: "Moustiquaire à battant",
        description: "La porte moustiquaire à battant allie esthétique et praticité avec un cadre entièrement en aluminium.",
        options: [
          "Profils en aluminium thermolaqué (8 RAL - couleur ton bois en option)",
          "Toile en fibre de verre enrobée de PVC (grise ou noire)",
          "Exclusivement en pose tableau (entre murs)",
          "Options : toile en acier inox, toile Poll-Tex® (90 % du pollen filtré), toile Sunox (traitement anti-bactérien), toile Petscreen, chatière, charnière de rappel (fermeture automatique)"
        ]
      }
    ]
  },
  {
    name: "Volets roulants",
    products: [
      {
        name: "Volet roulant pose rénovation",
        description: "L’installation de volets roulants contribue à améliorer le confort, la sécurité et la performance thermique de votre logement.",
        options: [
          "Coffre et coulisses en aluminium thermolaqué",
          "Lames en aluminium double paroi, bois ou PVC",
          "200 coloris RAL",
          "Largeur de 0,5 à 4,7m",
          "Hauteur de 0,5 à 4m",
          "Manoeuvre manuelle (tringle oscillante, sangle, tirage direct) ou motorisée (filaire, radio, solaire)",
          "Coffre pan coupé, 1⁄4 rond ou 1/2 rond design",
          "Options : moustiquaire, store intégré, projection"
        ]
      },
      {
        name: "Volet roulant pose traditionnelle",
        description: "Solution esthétique à la mise en œuvre simple, s’adapte à tous les types de coffres intérieurs du marché.",
        options: [
          "Coulisses en aluminium thermolaqué",
          "Lames en aluminium double paroi, bois ou PVC",
          "200 coloris RAL",
          "Largeur de 0,5 à 4,7m",
          "Hauteur de 0,5 à 4m",
          "Manoeuvre manuelle (tringle oscillante, sangle, tirage direct) ou motorisée (filaire, radio, solaire)",
          "Options : moustiquaire, store intégré"
        ]
      }
    ]
  },
  {
    name: "Volets battants",
    products: [
      {
        name: "Volet battant plein ou persienne",
        description: "Atout esthétique indéniable, le volet battant participe à l’amélioration énergétique de votre habitat.",
        options: [
          "Aluminium, bois ou PVC (200 coloris RAL)",
          "Arrêts : Marseillais, tête de bergère, à bascule, à paillettes, à poignée",
          "Condamnations : Espagnolette, crémone, crochet crémaillère, serrure",
          "Pentures : Festonnée trèfle, queue de carpe, penture réglable droite, penture réglable équerre",
          "Options : motorisation, cintrage, pré-cadre"
        ]
      },
      {
        name: "Motorisation volet battant",
        description: "Sur-mesure, esthétique et silencieuse, la motorisation s’adapte à tous les volets battants.",
        options: [
          "Motorisation filaire, radio ou solaire",
          "200 coloris RAL"
        ]
      }
    ]
  },
  {
    name: "Portes de garage",
    products: [
      {
        name: "Porte de garage enroulable",
        description: "Les portes de garage enroulables ont un système d’ouverture similaire à celui d’un volet roulant.",
        options: [
          "Coffre et coulisses en aluminium thermolaqué",
          "Lames en aluminium double paroi",
          "200 coloris RAL",
          "Largeur jusqu’à 4,6m",
          "Hauteur jusqu’à 4,26m",
          "Manoeuvre manuelle ou motorisée",
          "Sécurité : détection d’obstacles, système anti-chute du tablier, bloqueurs anti-soulèvement",
          "Options : digicode, commande murale, récepteur d’éclairage, lames hublots, feu clignotant à LED"
        ]
      },
      {
        name: "Porte de garage sectionnelle",
        description: "Les portes de garage sectionnelles sont conçues pour bénéficier d’une isolation thermique et phonique renforcée.",
        options: [
          "Panneaux en acier double paroi",
          "256 coloris RAL + 2 finitions bois",
          "Largeur jusqu’à 5,2m",
          "Hauteur jusqu’à 3,2m",
          "Manoeuvre manuelle ou motorisée",
          "Sécurité : détection d’obstacles, système anti-chute du tablier, bloqueurs anti-soulèvement",
          "Options : digicode, commande murale, récepteur d’éclairage, lames hublots, feu clignotant à LED"
        ]
      }
    ]
  }
]

# Créer les catégories, produits et options
categories_data.each do |category_data|
  category = Category.create!(name: category_data[:name])

  category_data[:products].each do |product_data|
    product = category.products.create!(name: product_data[:name], description: product_data[:description], brand: coublanc_brand)

    product_data[:options].each do |option_name|
      product.options.create!(content: option_name)
    end
  end
end

puts "Seed data created successfully."
