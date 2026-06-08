# frozen_string_literal: true

class PublicV2::CategoryIndexPage
  Section = Struct.new(
    :category,
    :products,
    :product_cards,
    :cover_image,
    :kicker,
    :title,
    :text,
    :tags,
    :empty_message,
    :anchor_id,
    :product_count,
    :short_title,
    :need_label,
    :accent_role,
    keyword_init: true
  ) do
    def href
      "##{anchor_id}"
    end
  end

  ProductCard = Struct.new(:product, :path, :image, :eyebrow, :description, keyword_init: true)
  AnchorItem = Struct.new(:anchor_id, :href, :label, :product_count, :accent_role, keyword_init: true)

  CATEGORY_CONTENT = {
    "Moustiquaires" => {
      short_title: "Moustiquaires",
      text: "Ventiler les pieces sans laisser entrer les insectes.",
      need_label: "Air et protection",
      tags: ["Fenetre", "Baie", "Porte"],
      accent_role: :accent_3
    },
    "Pergolas" => {
      short_title: "Pergolas",
      text: "Creer une zone de vie exterieure protegee.",
      need_label: "Terrasse",
      tags: ["Ombre", "Pluie legere", "Confort"],
      accent_role: :accent_1
    },
    "Portes de garage" => {
      short_title: "Portes de garage",
      text: "Securiser l'acces en gardant une ouverture fluide.",
      need_label: "Acces",
      tags: ["Garage", "Securite", "Motorisation"],
      accent_role: :accent_6
    },
    "Stores extérieurs" => {
      short_title: "Stores exterieurs",
      text: "Maitriser le soleil avant qu'il ne chauffe la maison.",
      need_label: "Soleil",
      tags: ["Terrasse", "Balcon", "Facade"],
      accent_role: :accent_1
    },
    "Stores intérieurs" => {
      short_title: "Stores interieurs",
      text: "Filtrer la lumiere et preserver l'intimite piece par piece.",
      need_label: "Lumiere",
      tags: ["Intimite", "Occultation", "Decoration"],
      accent_role: :accent_4
    },
    "Volets battants" => {
      short_title: "Volets battants",
      text: "Conserver le caractere de la facade avec une solution durable.",
      need_label: "Facade",
      tags: ["Renovation", "Teintes", "Motorisation"],
      accent_role: :accent_5
    },
    "Volets roulants" => {
      short_title: "Volets roulants",
      text: "Gagner en confort, isolation et pilotage au quotidien.",
      need_label: "Isolation",
      tags: ["Renovation", "Traditionnel", "Pilotage"],
      accent_role: :accent_2
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

  def product_total
    sections.sum(&:product_count)
  end

  def hero_kicker
    "Catalogue produits"
  end

  def hero_title
    "Toutes les solutions, par usage."
  end

  def hero_title_lines
    ["Solutions", "Par catégorie"]
  end

  def hero_text
    "Un acces direct aux gammes posees et conseillees par Les Artisans du Store."
  end

  def hero_proof_items
    [
      { value: product_total, label: "Produits", text: "Toutes les references visibles." },
      { value: category_count, label: "Familles", text: "Un parcours par usage." },
      { value: "Sur mesure", label: "Devis", text: "Pose et conseil local." }
    ]
  end

  def anchor_items
    @anchor_items ||= sections.map do |section|
      AnchorItem.new(
        anchor_id: section.anchor_id,
        href: section.href,
        label: section.short_title,
        product_count: section.product_count,
        accent_role: section.accent_role
      )
    end
  end

  def sections
    @sections ||= categories.map.with_index do |category, index|
      products = products_by_category_id[category.id] || []
      cover_product = cover_products[category.id] || products.first
      content = content_for(category)
      product_count = product_counts[category.id].to_i

      Section.new(
        category: category,
        products: products,
        product_cards: product_cards_for(products),
        cover_image: primary_image_for(cover_product),
        kicker: format("%02d", index + 1),
        title: category.name,
        text: content[:text],
        tags: content[:tags],
        empty_message: "Aucun produit affiche pour cette famille.",
        anchor_id: anchor_id_for(category),
        product_count: product_count,
        short_title: content[:short_title],
        need_label: content[:need_label],
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
        text: category.description.to_s.squish.presence || "Une selection a adapter selon l'usage, la pose et les finitions attendues.",
        need_label: "Projet",
        tags: products_by_category_id.fetch(category.id, []).first(3).map(&:name),
        accent_role: :accent_1
      }
    )
  end

  def product_cards_for(products)
    products.map do |product|
      ProductCard.new(
        product: product,
        path: product_path_builder.call(product),
        image: product_placeholder_image,
        eyebrow: product_eyebrow(product),
        description: product_description(product)
      )
    end
  end

  def product_placeholder_image
    "public_v2/product-placeholder.png"
  end

  def product_eyebrow(product)
    product.manufacturers.map(&:name).to_sentence.presence || "Les Artisans du Store"
  end

  def product_description(product)
    product.description.to_s.squish.presence ||
      product.infos.to_s.squish.presence ||
      "Produit configure selon les contraintes du projet."
  end

  def anchor_id_for(category)
    "categorie-#{category.id}"
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end
end
