# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Category.destroy_all

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
store_coffre = Product.create(category: store_exterieur, name: 'Stores coffres', description: 'Design , robuste , le store coffre peut couvrir une largeur de près de 12m')