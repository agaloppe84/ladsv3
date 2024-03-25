# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Category.destroy_all
Product.destroy_all
Option.destroy_all
Brand.destroy_all
Motorist.destroy_all
Ral.destroy_all





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

puts "Création des catégories - START"

# ------------------------- Création des types de stores ------------------------- #

store_exterieur =   Category.create!(name: 'Stores extérieurs', description: 'Adoptez la détente en extérieur', color: 'green')
pergostore =        Category.create!(name: 'Pergostores', description: 'Donnez vie à votre terrasse', color: 'green-blue')
pergola =           Category.create!(name: 'Pergolas', description: 'Donnez vie à votre terrasse', color: 'blue')
store_interieur =   Category.create!(name: 'Stores intérieurs', description: 'Jouez avec les couleurs et la lumière', color: 'pink')
volet_roulant =     Category.create!(name: 'Volets roulants', description: 'Confort thermique et sécurité', color: 'red')
volet_battant =     Category.create!(name: 'Volets battants', description: 'Confort thermique et sécurité', color: 'purple')
moustiquaire =      Category.create!(name: 'Moustiquaires', description: 'Protégez vous des insectes', color: 'yellow')
porte_de_garage =   Category.create!(name: 'Portes de garage', description: 'Les fermetures sur mesure', color: 'brown')

# ------------------------- Création des types de stores ------------------------- #


puts "----------------------------------------------------"
puts "CATEGORIES"
puts "----------------------------------------------------"

Category.all.each_with_index do |cat, index|
  puts "** #{index + 1} ** - #{cat.name} -- ID: #{cat.id}"
end
puts "----------------------------------------------------"


puts "Création des types de stores - END"
store_coffre = Product.create(category: store_exterieur,
                              name: 'Stores Coffres',
                              description: 'Design , robuste , le store coffre peut couvrir une largeur de près de 12m',
                              infos: "Fiez-vous aux apparences ! Le store coffre est un store robuste fait pour durer. Il peut couvrir une surface de près de 50m2. Ses 3 types de pose possibles , les nombreux coloris d'armature et de toile disponibles signent son adaptabilité.",
                              warranty: '7',
                              brand: coublanc_brand
                              )

store_coffre.images.attach(key: "#{store_exterieur.name}/#{store_coffre.name}/image-01", io: URI.open('https://res.cloudinary.com/dytbi4y5w/image/upload/v1704213937/LR_RS_0726_CUR_0089_rideau_1_b0enjq.jpg'), filename: "store coffre")

Option.create(product: store_coffre, content: "Profils en Aluminium extrudé blanc, ivoire et anthracite")
Option.create(product: store_coffre, content: "Manoeuvre electrique")
Option.create(product: store_coffre, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_coffre, content: "Tension optimisée de la toile")
Option.create(product: store_coffre, content: "Jusqu'a 4m d'avancée")
Option.create(product: store_coffre, content: "Largeur : de 1760 à 11880 mm")
Option.create(product: store_coffre, content: "Résistance au vent : selon dimension")
Option.create(product: store_coffre, content: "Option : Led sur bras, paresoleil, coloris")
# Add rals colors
store_coffre.rals << Ral.all.first
store_coffre.rals << Ral.all.last
store_coffre.rals << Ral.find(5)
# Add service
Service.create(product: store_coffre, warranty: store_coffre.warranty, free_quote: true, custom_dimensions: true, wind_resistance: true, anti_fire: true, anti_uv: true, rge: true, made_in_france: true)
# Add Motorist
store_coffre.motorists << somfy_motorist
store_coffre.motorists << wellcom_motorist



store_monobloc = Product.create(category: store_exterieur,
                              name: 'Stores Monoblocs',
                              description: 'Armature thermolaquée assurant à la fois résistance et discrétion',
                              infos: "Avec une avancée qui peut atteindre 4m , le store monobloc est idéal pour protéger tout types de terrasses , jusqu'a 17,72 m de largeur.",
                              warranty: '7',
                              brand: coublanc_brand
                              )

Option.create(product: store_monobloc, content: "Armature : 250 coloris")
Option.create(product: store_monobloc, content: "Manoeuvres : manuelle ou électrique")
Option.create(product: store_monobloc, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_monobloc, content: "Lambrequin droit ou à vagues")
Option.create(product: store_monobloc, content: "Jusqu'a 4m d'avancée")
Option.create(product: store_monobloc, content: "Largeur : jusqu'à 17,72m")
Option.create(product: store_monobloc, content: "Auvent de protection")



store_loggia = Product.create(category: store_exterieur,
                              name: 'Stores Loggia',
                              description: 'Pour une occultation presque totale de vos fenêtres',
                              infos: "Le store Loggia est le plus petit de tous nos stores extérieurs , en plus de pouvoir être fixé de face ou de plafond , c'est le seul modèle qui peut aussi être fixé latéralement , entre deux murs.",
                              warranty: '7',
                              brand: coublanc_brand
                              )

Option.create(product: store_loggia, content: "Armature : 84 couleurs standards")
Option.create(product: store_loggia, content: "inclinaison jusqu'a 85°")
Option.create(product: store_loggia, content: "Manoeuvres : manuelle ou électrique")
Option.create(product: store_loggia, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_loggia, content: "Lambrequin droit ou à vagues")
Option.create(product: store_loggia, content: "Fixation face ou plafond")
Option.create(product: store_loggia, content: "Avancée : de 1500 à 2500 mm")
Option.create(product: store_loggia, content: "Largeur : de 1750 à 5550 mm")


store_bannette = Product.create(category: store_exterieur,
                              name: 'Stores Bannette / Stores Toile ou conducteur',
                              description: 'Adaptés aux grandes surfaces vitrées',
                              infos: "A projection ou verticale , le store bannette est spécialement adapté à la protection des baies de très grandes dimensions . Selon la toile que vous choisirez , vous maîtriserez en douceur la lumière pour un meilleur confort thermique et visuel .",
                              warranty: '7',
                              brand: coublanc_brand
                              )

Option.create(product: store_bannette, content: "Types: Projection ou conducteur vertical")
Option.create(product: store_bannette, content: "Manoeuvres : manuelle ou électrique")
Option.create(product: store_bannette, content: "Armature: + de 180 coloris ")
Option.create(product: store_bannette, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_bannette, content: "Lambrequin droit ou à vagues")
Option.create(product: store_bannette, content: "Largeur maxi: 5.85m")
Option.create(product: store_bannette, content: "Auvent de protection")



abris_pentes = Product.create(category: store_exterieur,
                              name: 'Abris 2 pentes',
                              description: "Profitez de votre jardin en été sans avoir à souffrir du soleil",
                              infos: "L'abri 2 pentes est très apprécié pour sa simplicité d'utilisation et son confort déjà reconnu sur les terrasses des restaurants et bars . Il peut couvrir une grande surface et peut être fixé au sol grâce à ses platines de fixation.",
                              warranty: '7',
                              brand: coublanc_brand
                              )


Option.create(product: abris_pentes, content: "Manoeuvres : manuelle ou électrique")
Option.create(product: abris_pentes, content: "Lambrequin pare-soleil")
Option.create(product: abris_pentes, content: "Lambrequin droit ou à vagues")
Option.create(product: abris_pentes, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: abris_pentes, content: "Largeur: 2840 à 12 000 mm")
Option.create(product: abris_pentes, content: "Avancée: de 2m à 4m par côté")
Option.create(product: abris_pentes, content: "Hauteur: 3m maximum")


# Pergostores
lacharme = Product.create(category: pergostore,
                              name: 'PergoStore toiles Lacharme',
                              description: "Profitez en tout quiétude de votre extérieur",
                              infos: "Cette pergola vous protègera du soleil et de la pluie avec une toile Infinity Dickson enroulable zippée dans les rails de guidage. La technologie développée par Coublanc garantie un guidage de la barre de charge ainsi qu'une tension optimisée de la toile.",
                              warranty: '5',
                              brand: coublanc_brand
                              )


Option.create(product: lacharme, content: "Profils en Aluminium à haute résistance")
Option.create(product: lacharme, content: "Armature: coloris Gris Anthracite RAL 7016 ou Blanc RAL 9016 texturé")
Option.create(product: lacharme, content: "Fixation: Murale et 2 pieds à l'avant")
Option.create(product: lacharme, content: "Fermeture: Repli contre la façade")
Option.create(product: lacharme, content: "Largeur: jusqu'à 6m")
Option.create(product: lacharme, content: "Avancée: jusqu'à 5m")
Option.create(product: lacharme, content: "Option: Zip vertical et LED sur poteaux, rails et traverse")



espalis = Product.create(category: pergostore,
                              name: 'Espalis - Zip',
                              description: "Profitez en tout quiétude de votre extérieur. Le store coffre vertical zippé motorisé s'adapte sur nos pergolas,...",
                              infos: "Choisissez une toile PVC micro-perforée pour vous protéger du soleil tout en favorisant la circulation de l'air. Le store coffre vertical Espalis vous préserve du soleil, du vent et du vis à vis.",
                              warranty: '5',
                              brand: coublanc_brand
                              )


Option.create(product: espalis, content: "Profils en Aluminium extrudé")
Option.create(product: espalis, content: "Toile microperforée Soltis 88 ou Mermet 5500")
Option.create(product: espalis, content: "Fixation: Murale ou Autoportante")
Option.create(product: espalis, content: "Système à coulisses zippées")
Option.create(product: espalis, content: "Largeur: jusqu'à 5.75m")



# Pergolas
bioclim = Product.create(category: pergola,
                              name: 'Pergolas Bioclimatiques',
                              description: "Profitez d'un espace extérieur protégé",
                              infos: "Investir dans une pergola bioclimatique , c'est profiter d'un espace extérieur protégé , où rayons du soleil et pluie battante n'auront aucune incidence sur vos réceptions.",
                              warranty: '5',
                              brand: coublanc_brand
                              )


Option.create(product: bioclim, content: "Profils en Aluminium à haute résistance")
Option.create(product: bioclim, content: "Armature: Coloris gris Anthracite RAL 7016 ou Blanc RAL 9016 texturé")
Option.create(product: bioclim, content: "Fixation: Murale ou Autoportante")
Option.create(product: bioclim, content: "Fermetures: Latérales et frontales")
Option.create(product: bioclim, content: "Protection Soleil/Pluie/Vent")



puts "----------------------------------------------------"
puts "PRODUITS"
puts "----------------------------------------------------"

Product.all.each_with_index do |prod, index|
  puts "** #{index + 1} ** - #{prod.name} -- ID: #{prod.id}"
end
puts "----------------------------------------------------"
