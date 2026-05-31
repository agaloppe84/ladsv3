# frozen_string_literal: true

class PublicV2::CategoryIndexPage
  FEATURED_PRODUCT_LIMIT = 4

  Section = Struct.new(
    :category,
    :products,
    :cover_image,
    :kicker,
    :title,
    :text,
    :tags,
    :empty_message,
    :product_paths,
    :product_images,
    :anchor_id,
    :product_count,
    :short_title,
    :editorial_title,
    :editorial_text,
    :need_key,
    :need_label,
    :use_cases,
    :benefits,
    :decision_points,
    :featured_products,
    :featured_product_paths,
    :featured_product_images,
    :remaining_product_count,
    :cta_label,
    :accent_role,
    keyword_init: true
  ) do
    def href
      "##{anchor_id}"
    end

    def has_more_products?
      remaining_product_count.positive?
    end
  end

  AnchorItem = Struct.new(:anchor_id, :href, :label, :text, :product_count, :need_key, :accent_role, keyword_init: true)
  NeedItem = Struct.new(:key, :kicker, :title, :text, :points, :category_names, :anchor_hrefs, :accent_role, keyword_init: true)

  CATEGORY_CONTENT = {
    "Moustiquaires" => {
      short_title: "Moustiquaires",
      editorial_title: "Ventiler sans inviter les insectes.",
      text: "Ventiler sans laisser entrer les insectes, avec des poses discretes et pratiques.",
      editorial_text: "Pour ouvrir les pieces plus souvent, garder l'air qui circule et proteger les ouvertures sans alourdir la facade.",
      need_key: :daily_comfort,
      need_label: "Air et protection",
      tags: ["Enroulable", "Plissee", "Battant"],
      use_cases: ["Fenetre", "Baie", "Porte"],
      benefits: ["Air frais", "Pose discrete", "Usage quotidien"],
      decision_points: ["Type d'ouverture", "Frequence d'usage", "Discretion souhaitee"],
      cta_label: "Comparer les moustiquaires",
      accent_role: :accent_2
    },
    "Pergolas" => {
      short_title: "Pergolas",
      editorial_title: "Creer une vraie piece dehors.",
      text: "Creer un espace exterieur protege, confortable et utilisable plus longtemps.",
      editorial_text: "Une famille pour transformer la terrasse en zone de vie, avec structure, ombre, pluie legere et options de confort.",
      need_key: :sun_control,
      need_label: "Terrasse et ombre",
      tags: ["Bioclimatique", "Toile", "Terrasse"],
      use_cases: ["Terrasse", "Jardin", "Espace repas"],
      benefits: ["Ombre durable", "Confort exterieur", "Options integrees"],
      decision_points: ["Orientation", "Structure", "Eclairage"],
      cta_label: "Comparer les pergolas",
      accent_role: :accent_1
    },
    "Portes de garage" => {
      short_title: "Portes de garage",
      editorial_title: "Fermer juste, sans perdre de place.",
      text: "Securiser l'acces au garage avec une ouverture adaptee a l'espace disponible.",
      editorial_text: "Une entree utile quand l'espace, la securite et le confort d'ouverture comptent autant que l'esthetique.",
      need_key: :closure,
      need_label: "Acces et securite",
      tags: ["Sectionnelle", "Enroulable", "Motorisee"],
      use_cases: ["Garage", "Renovation", "Motorisation"],
      benefits: ["Gain de place", "Securite", "Usage fluide"],
      decision_points: ["Retombee", "Refoulement", "Commande"],
      cta_label: "Comparer les portes",
      accent_role: :neutral
    },
    "Stores extérieurs" => {
      short_title: "Stores exterieurs",
      editorial_title: "Maitriser le soleil avant qu'il n'entre.",
      text: "Gerer le soleil, la chaleur et l'eblouissement sur terrasse, balcon ou facade.",
      editorial_text: "La famille la plus directe pour ombrer une terrasse, proteger une baie ou garder une piece plus confortable en ete.",
      need_key: :sun_control,
      need_label: "Soleil et chaleur",
      tags: ["Banne", "Coffre", "Screen"],
      use_cases: ["Terrasse", "Balcon", "Baie vitree"],
      benefits: ["Ombre precise", "Chaleur reduite", "Toiles techniques"],
      decision_points: ["Exposition", "Largeur", "Protection toile"],
      cta_label: "Comparer les stores exterieurs",
      accent_role: :accent_1
    },
    "Stores intérieurs" => {
      short_title: "Stores interieurs",
      editorial_title: "Filtrer la lumiere piece par piece.",
      text: "Filtrer la lumiere, preserver l'intimite et habiller les pieces avec precision.",
      editorial_text: "Pour ajuster l'ambiance, l'intimite et l'usage quotidien sans engager de gros travaux.",
      need_key: :daily_comfort,
      need_label: "Lumiere et intimite",
      tags: ["Rouleau", "Venitien", "Textile"],
      use_cases: ["Salon", "Bureau", "Chambre"],
      benefits: ["Lumiere modulee", "Intimite", "Finitions fines"],
      decision_points: ["Occultation", "Matiere", "Commande"],
      cta_label: "Comparer les stores interieurs",
      accent_role: :accent_2
    },
    "Volets battants" => {
      short_title: "Volets battants",
      editorial_title: "Garder le caractere de la facade.",
      text: "Conserver le caractere de la facade avec des volets adaptes a l'existant.",
      editorial_text: "Une solution visible et durable pour respecter l'architecture tout en ameliorant confort et usage.",
      need_key: :closure,
      need_label: "Facade et renovation",
      tags: ["Battant", "Motorisation", "Renovation"],
      use_cases: ["Maison", "Renovation", "Facade"],
      benefits: ["Style conserve", "Materiaux durables", "Motorisation possible"],
      decision_points: ["Matiere", "Teinte", "Ferrage"],
      cta_label: "Comparer les volets battants",
      accent_role: :neutral
    },
    "Volets roulants" => {
      short_title: "Volets roulants",
      editorial_title: "Confort, securite et isolation au quotidien.",
      text: "Ameliorer le confort, la securite et l'isolation avec une solution motorisable.",
      editorial_text: "Une famille efficace pour moderniser les ouvertures, piloter facilement et gagner en confort thermique.",
      need_key: :closure,
      need_label: "Isolation et pilotage",
      tags: ["Renovation", "Traditionnel", "Motorise"],
      use_cases: ["Fenetre", "Baie", "Renovation"],
      benefits: ["Isolation", "Securite", "Motorisation"],
      decision_points: ["Type de coffre", "Tablier", "Commande"],
      cta_label: "Comparer les volets roulants",
      accent_role: :neutral
    }
  }.freeze

  NEED_CONTENT = [
    {
      key: :sun_control,
      kicker: "Soleil",
      title: "Ombre et chaleur",
      text: "Stores exterieurs et pergolas pour garder les espaces vivables.",
      points: ["Terrasse", "Baie", "Exposition"],
      category_names: ["Stores extérieurs", "Pergolas"],
      accent_role: :accent_1
    },
    {
      key: :closure,
      kicker: "Fermeture",
      title: "Fermer, isoler, securiser",
      text: "Volets et portes de garage pour proteger et simplifier le quotidien.",
      points: ["Isolation", "Securite", "Motorisation"],
      category_names: ["Volets roulants", "Volets battants", "Portes de garage"],
      accent_role: :neutral
    },
    {
      key: :daily_comfort,
      kicker: "Confort",
      title: "Lumiere et air au quotidien",
      text: "Stores interieurs et moustiquaires pour ajuster sans gros travaux.",
      points: ["Intimite", "Ventilation", "Discretion"],
      category_names: ["Stores intérieurs", "Moustiquaires"],
      accent_role: :accent_2
    }
  ].freeze

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
    "Choisir la bonne famille, sans se perdre dans le catalogue."
  end

  def hero_title_lines
    ["Choisir la bonne famille.", "Sans se perdre dans le catalogue."]
  end

  def hero_text
    "Stores, volets, portes, moustiquaires et pergolas : partez du besoin, comparez les familles, puis avancez vers le bon produit."
  end

  def hero_card_title
    "Un index pense pour le projet."
  end

  def hero_card_text
    "On commence par l'usage, on confirme la famille, puis on garde quelques produits reperes pour avancer sans rallonger la page."
  end

  def hero_panel_label
    "Index guide"
  end

  def hero_panel_text
    "Des entrees par usage, des produits reperes et des ancres stables pour passer de la home au bon bloc."
  end

  def cta_title
    "Un doute entre deux familles ?"
  end

  def catalog_kicker
    "Familles"
  end

  def catalog_title
    "Comparer par usage."
  end

  def catalog_text
    "Chaque famille garde son ancre, son role, ses produits reperes et les criteres utiles pour avancer vers le devis."
  end

  def anchor_rail_kicker
    "Navigation"
  end

  def anchor_rail_title
    "Aller au bon bloc."
  end

  def anchor_rail_text
    "Les ancres restent stables pour les liens depuis la home v2 et pour la navigation interne."
  end

  def needs_kicker
    "Besoins"
  end

  def needs_title
    "Le bon produit commence par l'usage."
  end

  def needs_text
    "Trois entrees simples pour eviter l'effet catalogue : soleil, fermeture ou confort quotidien."
  end

  def hero_image
    sections.find { |section| section.cover_image.present? }&.cover_image || "magasin-04.jpeg"
  end

  def hero_alt
    "Showroom Les Artisans du Store"
  end

  def hero_proof_items
    [
      { value: category_count, label: "Familles", text: "Un index court pour s'orienter." },
      { value: need_items.size, label: "Entrees besoin", text: "Soleil, fermeture, confort." },
      { value: "200m2", label: "Showroom", text: "Comparer les solutions." }
    ]
  end

  def guide_steps
    [
      { kicker: "01", title: "Besoin", text: "Soleil, fermeture, confort ou ventilation." },
      { kicker: "02", title: "Famille", text: "Identifier la solution la plus logique." },
      { kicker: "03", title: "Produit", text: "Comparer les reperes avant le devis." }
    ]
  end

  def trust_items
    [
      { value: "Conseil", label: "Lecture metier", text: "On part de l'usage reel." },
      { value: "Pose", label: "Equipe terrain", text: "La solution reste installable." },
      { value: "SAV", label: "Suivi local", text: "Un interlocuteur apres chantier." }
    ]
  end

  def comparison_items
    need_items.map do |item|
      { kicker: item.kicker, title: item.title, text: item.text, points: item.points }
    end
  end

  def anchor_items
    @anchor_items ||= sections.map do |section|
      AnchorItem.new(
        anchor_id: section.anchor_id,
        href: section.href,
        label: section.short_title,
        text: section.need_label,
        product_count: section.product_count,
        need_key: section.need_key,
        accent_role: section.accent_role
      )
    end
  end

  def need_items
    @need_items ||= NEED_CONTENT.map do |content|
      matched_sections = sections.select { |section| content[:category_names].include?(section.category.name) }

      NeedItem.new(
        key: content[:key],
        kicker: content[:kicker],
        title: content[:title],
        text: content[:text],
        points: content[:points],
        category_names: content[:category_names],
        anchor_hrefs: matched_sections.map(&:href),
        accent_role: content[:accent_role]
      )
    end
  end

  def sections
    @sections ||= categories.map.with_index do |category, index|
      products = products_by_category_id[category.id] || []
      cover_product = cover_products[category.id] || products.first
      content = content_for(category)
      featured_products = products.first(FEATURED_PRODUCT_LIMIT)
      product_count = product_counts[category.id].to_i

      Section.new(
        category: category,
        products: products,
        cover_image: primary_image_for(cover_product),
        kicker: "#{format('%02d', index + 1)} · #{product_count} produits",
        title: category.name,
        text: content[:text],
        tags: content[:tags],
        empty_message: "Aucun produit affiche pour cette famille.",
        product_paths: product_paths_for(products),
        product_images: product_images_for(products),
        anchor_id: anchor_id_for(category),
        product_count: product_count,
        short_title: content[:short_title],
        editorial_title: content[:editorial_title],
        editorial_text: content[:editorial_text],
        need_key: content[:need_key],
        need_label: content[:need_label],
        use_cases: content[:use_cases],
        benefits: content[:benefits],
        decision_points: content[:decision_points],
        featured_products: featured_products,
        featured_product_paths: product_paths_for(featured_products),
        featured_product_images: product_images_for(featured_products),
        remaining_product_count: [products.size - featured_products.size, 0].max,
        cta_label: content[:cta_label],
        accent_role: content[:accent_role]
      )
    end
  end

  private

  attr_reader :product_counts, :cover_products, :products_by_category_id, :primary_image_resolver, :product_path_builder

  def content_for(category)
    CATEGORY_CONTENT.fetch(
      category.name,
      {
        short_title: category.name,
        editorial_title: "#{category.name} sur mesure.",
        text: category.description.to_s.squish.presence || "Des solutions sur mesure a comparer avec l'equipe selon les contraintes du projet.",
        editorial_text: "Une famille a cadrer selon l'usage, la pose, les dimensions et le niveau de finition attendu.",
        need_key: :custom,
        need_label: "Projet sur mesure",
        tags: products_by_category_id.fetch(category.id, []).first(3).map(&:name),
        use_cases: ["Usage", "Pose", "Finitions"],
        benefits: ["Conseil", "Sur mesure", "Devis"],
        decision_points: ["Besoin", "Contraintes", "Budget"],
        cta_label: "Comparer cette famille",
        accent_role: :accent_1
      }
    )
  end

  def anchor_id_for(category)
    "categorie-#{category.id}"
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
