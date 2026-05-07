# frozen_string_literal: true

class PublicV2::HomePage
  CategoryCard = Struct.new(:category, :index, :cover_image, :product_count, keyword_init: true) do
    def number
      format("%02d", index + 1)
    end

    def description
      category.description.to_s.squish.presence || "Solutions sur mesure avec conseil et pose."
    end
  end

  def initialize(categories:, products:, destock_products:, featured_product:, category_product_counts:, category_cover_products:, primary_image_resolver:)
    @categories = categories
    @products = products
    @destock_products = destock_products
    @featured_product = featured_product
    @category_product_counts = category_product_counts
    @category_cover_products = category_cover_products
    @primary_image_resolver = primary_image_resolver
  end

  attr_reader :categories, :products

  def featured_product
    @featured_product || products.first
  end

  def featured_image
    primary_image_for(featured_product)
  end

  def quote_product_options
    quote_products.map { |product| [product.name, product.id] }
  end

  def quote_product_selected_id
    featured_product&.id
  end

  def category_cards
    @category_cards ||= categories.first(6).map.with_index do |category, index|
      CategoryCard.new(
        category: category,
        index: index,
        cover_image: primary_image_for(@category_cover_products[category.id]),
        product_count: @category_product_counts[category.id].to_i
      )
    end
  end

  def product_rows
    products.first(6)
  end

  def hero_proof_items
    [
      { value: "48h", label: "Premier retour devis", text: "Un cadrage rapide pour avancer." },
      { value: "200m2", label: "Showroom technique", text: "Comparer toiles, moteurs et finitions." },
      { value: "Local", label: "Conseil + pose", text: "Une equipe terrain dans le Rhone." }
    ]
  end

  def project_steps
    [
      { kicker: "01", title: "Cadrer", text: "Produit, exposition, contraintes." },
      { kicker: "02", title: "Comparer", text: "Options utiles, finitions, pose." },
      { kicker: "03", title: "Chiffrer", text: "Retour clair avant decision." }
    ]
  end

  def comparison_items
    [
      { kicker: "Soleil", title: "Stores et pergolas", text: "Ombre, chaleur, terrasse.", points: ["Toile", "Structure", "Motorisation"] },
      { kicker: "Fermeture", title: "Volets et garage", text: "Confort, securite, usage quotidien.", points: ["Isolation", "Tablier", "Commande"] },
      { kicker: "Confort", title: "Moustiquaires", text: "Ventiler sans subir les nuisibles.", points: ["Discretion", "Pose", "Entretien"] }
    ]
  end

  def trust_items
    [
      { value: "35 ans", label: "Experience metier", text: "Des projets suivis localement." },
      { value: "RGE", label: "Expertise visible", text: "Un signal clair de confiance." },
      { value: "SAV", label: "Suivi apres pose", text: "Une equipe joignable." }
    ]
  end

  private

  attr_reader :destock_products, :primary_image_resolver

  def quote_products
    (products + destock_products).uniq.first(12)
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end
end
