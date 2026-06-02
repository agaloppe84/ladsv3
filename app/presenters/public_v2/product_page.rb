# frozen_string_literal: true

class PublicV2::ProductPage
  PREVIEW_SWATCH_LIMIT = 8

  InfoItem = Struct.new(:label, :text, keyword_init: true)
  OptionItem = Struct.new(:number, :content, keyword_init: true)
  Swatch = Struct.new(:title, :color, :meta, :ref, :name, :finish_label, :paid_option, keyword_init: true)
  PaletteSection = Struct.new(:code, :label, :name, :count, :swatches, :preview_swatches, :hidden_swatch_count, :modal_title, keyword_init: true)
  ServiceItem = Struct.new(:label, :enabled, :value, :text, :accent_role, keyword_init: true)
  GallerySlide = Struct.new(:image, :alt, :caption, :position, keyword_init: true)
  RelatedProduct = Struct.new(:product, :path, :image, keyword_init: true)
  BrandItem = Struct.new(:name, :kind, keyword_init: true)

  def initialize(product:, category:, color_parts:, related_products:, primary_image_resolver:, product_path_builder:, home_path:, catalog_path:, quote_path:, dickson_configurator_path: nil)
    @product = product
    @category = category
    @color_parts = color_parts
    @related_products = related_products
    @primary_image_resolver = primary_image_resolver
    @product_path_builder = product_path_builder
    @home_path = home_path
    @catalog_path = catalog_path
    @quote_path = quote_path
    @dickson_configurator_path = dickson_configurator_path
  end

  attr_reader :product, :category, :related_products, :catalog_path, :quote_path, :dickson_configurator_path

  def title
    "#{product.name} - Public V2"
  end

  def description
    product.description.to_s.squish.presence || "Fiche produit Public V2 Les Artisans du Store."
  end

  def gallery_images
    @gallery_images ||=
      if product.images_attachments.loaded?
        product.images_attachments.to_a.sort_by { |attachment| [attachment.position || 999_999, attachment.id || 0] }
      else
        product.ordered_images.to_a
      end
  end

  def gallery_slides
    @gallery_slides ||= gallery_images.each_with_index.map do |image, index|
      GallerySlide.new(
        image: image,
        alt: "#{product.name} - photo #{index + 1}",
        caption: "#{product.name} - photo #{index + 1}",
        position: index + 1
      )
    end
  end

  def hero_gallery_items
    @hero_gallery_items ||=
      if gallery_slides.any?
        gallery_slides.each_with_index.map do |slide, index|
          {
            image: slide.image,
            alt: slide.alt,
            modal_image: slide.image,
            modal_alt: slide.alt,
            modal_caption: slide.caption,
            action: :modal,
            image_ratio: :product,
            loading: index.zero? ? "eager" : "lazy",
            classes: "pv2-product-hero-v2__gallery-slide pv2-product-hero-v2__gallery-slide--modal"
          }
        end
      else
        [
          {
            image: nil,
            fallback: "placeholder.jpg",
            alt: product.name,
            title: "Photo a venir",
            text: "Le showroom permet de voir les finitions et details du produit.",
            action: :none,
            image_ratio: :product,
            loading: "eager",
            classes: "pv2-product-hero-v2__gallery-slide pv2-product-hero-v2__gallery-slide--empty"
          }
        ]
      end
  end

  def hero_gallery_modal?
    gallery_slides.any?
  end

  def color_count
    palette_sections.sum(&:count)
  end

  def brand_panel?
    brand_items.any?
  end

  def manufacturers_text
    product.manufacturers.map(&:name).to_sentence
  end

  def motorists_text
    product.motorists.map(&:name).to_sentence
  end

  def brand_items
    @brand_items ||= begin
      brands = product.manufacturers.map { |manufacturer| brand_item_for(manufacturer, :manufacturer) }
      brands += product.motorists.map { |motorist| brand_item_for(motorist, :motorist) }
      brands.compact.uniq { |brand| normalize_brand_key(brand.name) }
    end
  end

  def brand_names_text
    brand_items.map(&:name).join(" / ")
  end

  def warranty_card_value
    warranty_value.to_s.squish.sub(/\bans?\z/i) { |unit| unit.capitalize }.presence
  end

  def warranty_card_details
    service = product.service
    [
      ("Made in France" if service&.made_in_france),
      ("Dimensions sur mesure" if service&.custom_dimensions)
    ].compact
  end

  def dickson_configurator?
    product.manufacturers.any? { |manufacturer| manufacturer.name.to_s.match?(/dickson/i) }
  end

  def information_items
    base_items = [
      InfoItem.new(label: "Description", text: product.description.to_s.squish.presence),
      InfoItem.new(label: "Infos techniques", text: product.infos.to_s.squish.presence),
      InfoItem.new(label: "Dimensions", text: product.dimensions.to_s.squish.presence),
      InfoItem.new(label: "Garantie", text: warranty_value.presence),
      InfoItem.new(label: "Categorie", text: category.name),
      InfoItem.new(label: "Fabricants", text: manufacturers_text.presence),
      InfoItem.new(label: "Motorisations", text: motorists_text.presence)
    ]

    (price_items + base_items).select { |item| item.text.present? }
  end

  def option_items
    ordered_options.each_with_index.map do |option, index|
      OptionItem.new(number: format("%02d", index + 1), content: option.content)
    end
  end

  def palette_sections
    @palette_sections ||= color_parts.filter_map do |part|
      next if part.color_palette.blank?

      swatches = ordered_palette_items_for(part).map { |item| swatch_for(item) }

      PaletteSection.new(
        code: part.code,
        label: part.label,
        name: part.color_palette.name,
        count: swatches.size,
        swatches: swatches,
        preview_swatches: swatches.first(PREVIEW_SWATCH_LIMIT),
        hidden_swatch_count: [swatches.size - PREVIEW_SWATCH_LIMIT, 0].max,
        modal_title: "Tous les coloris #{part.label.to_s.downcase.presence || part.code.to_s.downcase}"
      )
    end
  end

  def service_items
    @service_items ||= service_item_definitions.filter_map do |definition|
      next unless definition[:enabled]

      ServiceItem.new(**definition)
    end
  end

  def documentation_items
    @documentation_items ||= product.documentations.attachments.to_a.sort_by { |attachment| attachment.filename.to_s }
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

  def partners_path
    "#{home_path}#public-v2-partners-title"
  end

  private

  attr_reader :color_parts, :primary_image_resolver, :product_path_builder, :home_path

  def warranty_text
    product.warranty.to_s.squish.presence || product.service&.warranty.to_s.squish.presence
  end

  def warranty_value
    value = warranty_text
    return if value.blank?
    return value if value.match?(/ans?\z/i)

    "#{value} ans"
  end

  def price_items
    [
      InfoItem.new(label: "Ancien prix", text: product.old_price.to_s.squish.presence),
      InfoItem.new(label: "Nouveau prix", text: product.new_price.to_s.squish.presence)
    ].select { |item| item.text.present? }
  end

  def swatch_for(item)
    ral = item.ral
    finish = item.finish
    ref = ral&.ref.to_s.squish.presence
    name = ral&.name.to_s.squish.presence
    finish_label = finish&.label.to_s.squish.presence
    meta = [
      finish_label,
      ("Option payante" if item.paid_option?)
    ].compact_blank.join(" / ")

    Swatch.new(
      title: [ref, name].compact_blank.join(" - "),
      color: swatch_color(ral),
      meta: meta,
      ref: ref,
      name: name,
      finish_label: finish_label,
      paid_option: item.paid_option?
    )
  end

  def ordered_palette_items_for(part)
    part.color_palette.color_palette_items.to_a.sort_by do |item|
      [
        item.ral&.collection.to_s,
        item.ral&.ref.to_s,
        item.ral&.name.to_s,
        item.finish&.label.to_s,
        item.id || 0
      ]
    end
  end

  def swatch_color(ral)
    raw_color = ral&.hex.presence || ral&.rgb.presence || "#d8d8d8"
    color = raw_color.to_s.strip

    return color if color.match?(/\A#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\z/)
    return color if color.match?(/\A(?:rgb|hsl)a?\([\d\s,%.+-]+\)\z/i)
    return "rgb(#{color})" if color.match?(/\A\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}(?:\s*,\s*(?:0|1|0?\.\d+))?\z/)
    return "##{color}" if color.match?(/\A(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\z/)

    "#d8d8d8"
  end

  def service_item_definitions
    service = product.service

    [
      {
        label: "Garantie",
        value: warranty_value,
        text: "Couverture produit",
        enabled: warranty_text.present?,
        accent_role: :accent_5
      },
      {
        label: "Sur mesure",
        value: "Oui",
        text: "Dimensions adaptees",
        enabled: service&.custom_dimensions,
        accent_role: :accent_1
      },
      {
        label: "Devis gratuit",
        value: "0 EUR",
        text: "Premier cadrage",
        enabled: service&.free_quote,
        accent_role: :accent_3
      },
      {
        label: "Anti feu",
        value: "Feu",
        text: "Protection specifique",
        enabled: service&.anti_fire,
        accent_role: :accent_6
      },
      {
        label: "Made in",
        value: "France",
        text: "Selon produit",
        enabled: service&.made_in_france,
        accent_role: :accent_2
      },
      {
        label: "Anti UV",
        value: "UV",
        text: "Protection solaire",
        enabled: service&.anti_uv,
        accent_role: :accent_4
      },
      {
        label: "RGE",
        value: "RGE",
        text: "Qualification",
        enabled: service&.rge,
        accent_role: :accent_3
      },
      {
        label: "Resistance au vent",
        value: "Vent",
        text: "Tenue renforcee",
        enabled: service&.wind_resistance,
        accent_role: :accent_1
      }
    ]
  end

  def primary_image_for(product)
    primary_image_resolver.call(product) if product.present?
  end

  def brand_item_for(brand, kind)
    name = brand.name.to_s.squish
    return if name.blank?

    BrandItem.new(name: name, kind: kind)
  end

  def normalize_brand_key(name)
    I18n.transliterate(name.to_s).downcase.gsub(/[^a-z0-9]+/, " ").squish
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
