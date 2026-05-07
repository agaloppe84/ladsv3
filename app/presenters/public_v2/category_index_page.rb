# frozen_string_literal: true

class PublicV2::CategoryIndexPage
  Section = Struct.new(:category, :products, :cover_image, :kicker, :title, :text, :tags, :empty_message, :product_paths, :product_images, keyword_init: true)

  CATEGORY_CONTENT = {
    "Moustiquaires" => {
      text: "Ventiler sans laisser entrer les insectes, avec des poses discretes et pratiques.",
      tags: ["Enroulable", "Plissee", "Battant"]
    },
    "Pergolas" => {
      text: "Creer un espace exterieur protege, confortable et utilisable plus longtemps.",
      tags: ["Bioclimatique", "Toile", "Terrasse"]
    },
    "Portes de garage" => {
      text: "Securiser l'acces au garage avec une ouverture adaptee a l'espace disponible.",
      tags: ["Sectionnelle", "Enroulable", "Motorisee"]
    },
    "Stores extérieurs" => {
      text: "Gerer le soleil, la chaleur et l'eblouissement sur terrasse, balcon ou facade.",
      tags: ["Banne", "Coffre", "Screen"]
    },
    "Stores intérieurs" => {
      text: "Filtrer la lumiere, preserver l'intimite et habiller les pieces avec precision.",
      tags: ["Rouleau", "Venitien", "Textile"]
    },
    "Volets battants" => {
      text: "Conserver le caractere de la facade avec des volets adaptes a l'existant.",
      tags: ["Battant", "Motorisation", "Renovation"]
    },
    "Volets roulants" => {
      text: "Ameliorer le confort, la securite et l'isolation avec une solution motorisable.",
      tags: ["Renovation", "Traditionnel", "Motorise"]
    }
  }.freeze

  def initialize(categories:, product_counts:, cover_products:, products_by_category_id:, primary_image_resolver:, product_path_builder:)
    @categories = categories
    @product_counts = product_counts
    @cover_products = cover_products
    @products_by_category_id = products_by_category_id
    @primary_image_resolver = primary_image_resolver
    @product_path_builder = product_path_builder
  end

  attr_reader :categories

  def category_count
    categories.size
  end

  def hero_kicker
    "Produits"
  end

  def hero_title
    "Comparer les familles avant devis."
  end

  def hero_text
    "Stores, volets, portes, moustiquaires et pergolas : chaque famille aide a cadrer l'usage, la pose et les options utiles avant de demander un prix."
  end

  def hero_panel_label
    "Catalogue guide"
  end

  def hero_panel_text
    "Des familles lisibles, des produits reperes et un conseil showroom pour eviter le mauvais choix."
  end

  def cta_title
    "Un doute entre deux familles ?"
  end

  def hero_image
    sections.find { |section| section.cover_image.present? }&.cover_image || "magasin-04.jpeg"
  end

  def hero_alt
    "Showroom Les Artisans du Store"
  end

  def hero_proof_items
    [
      { value: category_count, label: "Familles", text: "Pour partir du bon usage." },
      { value: "48h", label: "Retour devis", text: "Premier cadrage commercial." },
      { value: "200m2", label: "Showroom", text: "Comparer les solutions." }
    ]
  end

  def guide_steps
    [
      { kicker: "01", title: "Usage", text: "Soleil, fermeture, confort ou securite." },
      { kicker: "02", title: "Contrainte", text: "Pose, dimensions, exposition, existant." },
      { kicker: "03", title: "Solution", text: "Produit, options et niveau de devis." }
    ]
  end

  def trust_items
    [
      { value: "Conseil", label: "Lecture metier", text: "On part du besoin reel." },
      { value: "Pose", label: "Equipe terrain", text: "La solution reste installable." },
      { value: "SAV", label: "Suivi local", text: "Un interlocuteur apres chantier." }
    ]
  end

  def comparison_items
    [
      { kicker: "Exterieur", title: "Ombre et chaleur", text: "Stores, pergolas, screens.", points: ["Terrasse", "Baie", "Soleil"] },
      { kicker: "Habitat", title: "Fermer et isoler", text: "Volets et portes de garage.", points: ["Securite", "Confort", "Moteur"] },
      { kicker: "Quotidien", title: "Ventiler et proteger", text: "Moustiquaires et stores interieurs.", points: ["Fenetre", "Lumiere", "Discret"] }
    ]
  end

  def sections
    @sections ||= categories.map.with_index do |category, index|
      products = products_by_category_id[category.id] || []
      cover_product = cover_products[category.id] || products.first
      content = content_for(category)

      Section.new(
        category: category,
        products: products,
        cover_image: primary_image_for(cover_product),
        kicker: "#{format('%02d', index + 1)} · #{product_counts[category.id].to_i} produits",
        title: category.name,
        text: content[:text],
        tags: content[:tags],
        empty_message: "Aucun produit affiche pour cette famille.",
        product_paths: product_paths_for(products),
        product_images: product_images_for(products)
      )
    end
  end

  private

  attr_reader :product_counts, :cover_products, :products_by_category_id, :primary_image_resolver, :product_path_builder

  def content_for(category)
    CATEGORY_CONTENT.fetch(
      category.name,
      {
        text: category.description.to_s.squish.presence || "Des solutions sur mesure a comparer avec l'equipe selon les contraintes du projet.",
        tags: products_by_category_id.fetch(category.id, []).first(3).map(&:name)
      }
    )
  end

  def product_paths_for(products)
    products.index_with { |product| product_path_builder.call(product) }
  end

  def product_images_for(products)
    products.index_with { |product| primary_image_for(product) }
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end
end
