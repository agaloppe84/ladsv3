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
    "Choisir la bonne solution."
  end

  def hero_text
    "Stores, volets, portes, moustiquaires et pergolas : les familles sont regroupees pour comparer les usages, les produits et les options utiles."
  end

  def hero_panel_label
    "Familles"
  end

  def hero_panel_text
    "Des solutions visibles au showroom, avec conseil et pose."
  end

  def cta_title
    "Parlez-nous du projet."
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
