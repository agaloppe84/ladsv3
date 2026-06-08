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

  HeroCategoryCard = Struct.new(:category, :index, :key, :label, :image, :alt, :kicker, :title, :accent_title, :accent, keyword_init: true)

  HERO_CATEGORY_INITIAL_SLUG = "stores-interieurs"

  HERO_FALLBACK_ASSETS = [
    {
      image: "public_v2/hero-interior-blind-closeup-cgi.png",
      alt: "Store intérieur premium type Duette en gros plan sur fond blanc"
    },
    {
      image: "public_v2/hero-pergola-closeup-cgi.png",
      alt: "Pergola bioclimatique premium en gros plan vue de dessus sur fond blanc"
    },
    {
      image: "public_v2/hero-mosquito-screen-closeup-cgi.png",
      alt: "Moustiquaire premium en gros plan vue de face sur fond blanc"
    },
    {
      image: "public_v2/hero-awning-box-closeup-cgi.png",
      alt: "Store banne coffre premium en gros plan vue de dessus sur fond blanc"
    }
  ].freeze

  HERO_CATEGORY_CONTENT = {
    "moustiquaires" => {
      kicker: "Moustiquaires",
      title: "Air frais",
      accent_title: "protégé",
      accent: "var(--pv2-style-accent-3)",
      fallback_asset: HERO_FALLBACK_ASSETS[2]
    },
    "pergolas" => {
      kicker: "Pergolas",
      title: "Ombre",
      accent_title: "précise",
      accent: "var(--pv2-style-accent-orange)",
      fallback_asset: HERO_FALLBACK_ASSETS[1]
    },
    "portes-de-garage" => {
      kicker: "Portes de garage",
      title: "Accès",
      accent_title: "sécurisé",
      accent: "var(--pv2-style-accent-1)"
    },
    "stores-exterieurs" => {
      kicker: "Stores extérieurs",
      title: "Terrasse",
      accent_title: "ombragée",
      accent: "var(--pv2-style-accent-orange)",
      fallback_asset: HERO_FALLBACK_ASSETS[3]
    },
    "stores-interieurs" => {
      kicker: "Stores intérieurs",
      title: "Lumière",
      accent_title: "maîtrisée",
      accent: "var(--pv2-style-accent-fresh)",
      fallback_asset: HERO_FALLBACK_ASSETS[0]
    },
    "volets-battants" => {
      kicker: "Volets battants",
      title: "Façade",
      accent_title: "préservée",
      accent: "var(--pv2-style-accent-2)"
    },
    "volets-roulants" => {
      kicker: "Volets roulants",
      title: "Confort",
      accent_title: "isolé",
      accent: "var(--pv2-style-accent-4)"
    },
    "pergostores" => {
      kicker: "Pergostores",
      title: "Abri",
      accent_title: "modulé",
      accent: "var(--pv2-style-accent-orange)"
    }
  }.freeze

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
    @category_cards ||= categories.map.with_index do |category, index|
      CategoryCard.new(
        category: category,
        index: index,
        cover_image: primary_image_for(@category_cover_products[category.id]),
        product_count: @category_product_counts[category.id].to_i
      )
    end
  end

  def hero_category_cards
    @hero_category_cards ||= categories.map.with_index do |category, index|
      content = hero_category_content_for(category)
      fallback_asset = content[:fallback_asset] || hero_fallback_asset_for(index)

      HeroCategoryCard.new(
        category: category,
        index: index,
        key: hero_category_key(category),
        label: category.name.to_s.presence || content[:kicker],
        image: hero_category_image_for(category, fallback_asset),
        alt: hero_category_alt_for(category, fallback_asset),
        kicker: content[:kicker] || category.name.to_s,
        title: content[:title] || category.name.to_s,
        accent_title: content[:accent_title] || "sur mesure",
        accent: content[:accent] || "var(--pv2-style-accent-orange)"
      )
    end
  end

  def hero_category_initial_index
    hero_category_cards.index { |card| card.key == HERO_CATEGORY_INITIAL_SLUG } || 0
  end

  def product_rows
    products.first(6)
  end

  def hero_proof_items
    [
      { value: "48h", label: "Premier retour devis", text: "Un cadrage rapide pour avancer." },
      { value: "200m2", label: "Showroom technique", text: "Comparer toiles, moteurs et finitions." },
      { value: "Local", label: "Conseil + pose", text: "Une équipe terrain dans le Rhône." }
    ]
  end

  def project_steps
    [
      { kicker: "01", title: "Cadrer", text: "Produit, exposition, contraintes." },
      { kicker: "02", title: "Comparer", text: "Options utiles, finitions, pose." },
      { kicker: "03", title: "Chiffrer", text: "Retour clair avant décision." }
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
      { value: "35 ans", label: "Expérience métier", text: "Des projets suivis localement." },
      { value: "RGE", label: "Expertise visible", text: "Un signal clair de confiance." },
      { value: "SAV", label: "Suivi après pose", text: "Une équipe joignable." }
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

  def hero_category_key(category)
    category.name.to_s.parameterize.presence || "category-#{category.id}"
  end

  def hero_category_content_for(category)
    HERO_CATEGORY_CONTENT.fetch(hero_category_key(category), {})
  end

  def hero_category_image_for(category, fallback_asset)
    return category.hero_image if category.hero_image.attached?

    fallback_asset[:image]
  end

  def hero_category_alt_for(category, fallback_asset)
    if category.hero_image.attached?
      return "Visuel détouré de la catégorie #{category.name}"
    end

    fallback_asset[:alt]
  end

  def hero_fallback_asset_for(index)
    HERO_FALLBACK_ASSETS[index % HERO_FALLBACK_ASSETS.size]
  end
end
