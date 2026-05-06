# frozen_string_literal: true

class PublicV2::ProductPage
  InfoItem = Struct.new(:label, :text, keyword_init: true)
  OptionItem = Struct.new(:number, :content, keyword_init: true)
  Swatch = Struct.new(:title, :color, keyword_init: true)
  PaletteSection = Struct.new(:code, :label, :name, :count, :swatches, keyword_init: true)
  ServiceItem = Struct.new(:label, :enabled, keyword_init: true)
  RelatedProduct = Struct.new(:product, :path, :image, keyword_init: true)

  def initialize(product:, category:, color_parts:, related_products:, primary_image_resolver:, product_path_builder:, home_path:, catalog_path:, quote_path:)
    @product = product
    @category = category
    @color_parts = color_parts
    @related_products = related_products
    @primary_image_resolver = primary_image_resolver
    @product_path_builder = product_path_builder
    @home_path = home_path
    @catalog_path = catalog_path
    @quote_path = quote_path
  end

  attr_reader :product, :category, :related_products, :catalog_path, :quote_path

  def title
    "#{product.name} - Public V2"
  end

  def description
    product.description.to_s.squish.presence || "Fiche produit Public V2 Les Artisans du Store."
  end

  def hero_image
    primary_image_for(product)
  end

  def gallery_images
    @gallery_images ||=
      if product.images_attachments.loaded?
        product.images_attachments.to_a.sort_by { |attachment| [attachment.position || 999_999, attachment.id || 0] }
      else
        product.ordered_images.to_a
      end
  end

  def color_count
    color_parts.sum { |part| part.color_palette&.color_palette_items&.size.to_i }
  end

  def brand_panel?
    product.manufacturers.any? || product.motorists.any?
  end

  def manufacturers_text
    product.manufacturers.map(&:name).to_sentence
  end

  def motorists_text
    product.motorists.map(&:name).to_sentence
  end

  def information_items
    [
      InfoItem.new(label: "Description", text: product.description.to_s.squish.presence || "Description a completer selon le projet."),
      InfoItem.new(label: "Infos techniques", text: product.infos.to_s.squish.presence || "L'equipe precise les contraintes techniques au moment du devis."),
      InfoItem.new(label: "Garantie", text: product.warranty.to_s.squish.presence || product.service&.warranty.to_s.squish.presence || "Garantie selon produit et configuration."),
      InfoItem.new(label: "Dimensions", text: product.dimensions.to_s.squish.presence || "Dimensions sur mesure apres prise de cotes.")
    ]
  end

  def option_items
    ordered_options.each_with_index.map do |option, index|
      OptionItem.new(number: format("%02d", index + 1), content: option.content)
    end
  end

  def palette_sections
    color_parts.map do |part|
      palette_items = part.color_palette.color_palette_items.to_a

      PaletteSection.new(
        code: part.code,
        label: part.label,
        name: part.color_palette.name,
        count: palette_items.size,
        swatches: palette_items.first(10).map { |item| swatch_for(item) }
      )
    end
  end

  def service_items
    return [] unless product.service.present?

    {
      "Dimensions sur mesure" => product.service.custom_dimensions,
      "Devis gratuit" => product.service.free_quote,
      "Fabrication France" => product.service.made_in_france,
      "Protection UV" => product.service.anti_uv,
      "RGE" => product.service.rge,
      "Resistance au vent" => product.service.wind_resistance
    }.map { |label, enabled| ServiceItem.new(label: label, enabled: enabled) }
  end

  def related_cards
    related_products.map do |related_product|
      RelatedProduct.new(
        product: related_product,
        path: product_path_builder.call(related_product),
        image: primary_image_for(related_product)
      )
    end
  end

  def breadcrumb_items
    [
      { label: "Accueil", path: home_path },
      { label: "Produits", path: catalog_path },
      { label: category.name }
    ]
  end

  private

  attr_reader :color_parts, :primary_image_resolver, :product_path_builder, :home_path

  def swatch_for(item)
    ral = item.ral

    Swatch.new(
      title: [ral&.ref, ral&.name].compact.join(" - "),
      color: ral&.hex.presence || ral&.rgb.presence || "#d8d8d8"
    )
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end

  def ordered_options
    product.options.to_a.sort_by do |option|
      [
        option.order.present? ? option.order : 999_999,
        option.created_at || Time.zone.at(0),
        option.id || 0
      ]
    end
  end
end
