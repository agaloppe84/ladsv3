# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Category.destroy_all
Product.destroy_all

puts "Création des catégories - START"

# ------------------------- Création des types de stores ------------------------- #

store_exterieur =   Category.create!(name: 'Stores extérieurs', description: 'Adoptez la détente en extérieur')
pergostore =        Category.create!(name: 'Pergostores', description: 'Donnez vie à votre terrasse')
pergola =           Category.create!(name: 'Pergolas', description: 'Donnez vie à votre terrasse')
store_interieur =   Category.create!(name: 'Stores intérieurs', description: 'Jouez avec les couleurs et la lumière')
volet_roulant =     Category.create!(name: 'Volets roulants', description: 'Confort thermique et sécurité')
volet_battant =     Category.create!(name: 'Volets battants', description: 'Confort thermique et sécurité')
moustiquaire =      Category.create!(name: 'Moustiquaires', description: 'Protégez vous des insectes')
porte_de_garage =   Category.create!(name: 'Portes de garage', description: 'Les fermetures sur mesure')

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
                              warranty: '7'
                              )

Option.create(product: store_coffre, content: "Profils en Aluminium extrudé blanc, ivoire et anthracite")
Option.create(product: store_coffre, content: "Manoeuvre electrique")
Option.create(product: store_coffre, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_coffre, content: "Tension optimisée de la toile")
Option.create(product: store_coffre, content: "Jusqu'a 4m d'avancée")
Option.create(product: store_coffre, content: "Largeur : de 1760 à 11880 mm")
Option.create(product: store_coffre, content: "Résistance au vent : selon dimension")
Option.create(product: store_coffre, content: "Option : Led sur bras, paresoleil, coloris")


store_monobloc = Product.create(category: store_exterieur,
                              name: 'Stores Monoblocs',
                              description: 'Armature thermolaquée assurant à la fois résistance et discrétion',
                              infos: "Avec une avancée qui peut atteindre 4m , le store monobloc est idéal pour protéger tout types de terrasses , jusqu'a 17,72 m de largeur.",
                              warranty: '7'
                              )

Option.create(product: store_monobloc, content: "Armature : 250 coloris")
Option.create(product: store_monobloc, content: "Manoeuvres : manuelle ou électrique")
Option.create(product: store_monobloc, content: "Toile : Acrylique teinté masse 270 couleurs (unis ou à rayures)")
Option.create(product: store_monobloc, content: "Lambrequin droit ou à vagues")
Option.create(product: store_monobloc, content: "Jusqu'a 4m d'avancée")
Option.create(product: store_monobloc, content: "Largeur : jusqu'à 17,72m")
Option.create(product: store_monobloc, content: "Auvent de protection")
