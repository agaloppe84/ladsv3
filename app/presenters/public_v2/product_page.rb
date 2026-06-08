# frozen_string_literal: true

class PublicV2::ProductPage
  PREVIEW_SWATCH_LIMIT = 8

  InfoItem = Struct.new(:label, :text, keyword_init: true)
  OptionItem = Struct.new(:number, :content, keyword_init: true)
  Swatch = Struct.new(:title, :color, :meta, :ref, :name, :finish_label, :paid_option, keyword_init: true)
  PaletteSection = Struct.new(:code, :label, :name, :count, :swatches, :preview_swatches, :hidden_swatch_count, :modal_title, keyword_init: true)
  AnimatedServiceCard = Struct.new(:key, :label, :protected_label, :impact_label, :variant, keyword_init: true)
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
    "#{product.name} - Les Artisans du Store"
  end

  def description
    product.description.to_s.squish.presence || "Fiche produit Les Artisans du Store : conseil, pose et devis sur mesure."
  end

  def keywords
    [
      product.name,
      category&.name,
      "stores",
      "volets roulants",
      "pergolas",
      "moustiquaires",
      "L'Arbresle"
    ].compact.join(", ")
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

  def made_in_france?
    product.service&.made_in_france?
  end

  def animated_service_cards
    @animated_service_cards ||= animated_service_card_definitions.filter_map do |definition|
      next unless definition[:enabled]

      AnimatedServiceCard.new(
        key: definition[:key],
        label: definition[:label],
        protected_label: definition[:protected_label],
        impact_label: definition[:impact_label],
        variant: definition[:variant]
      )
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
    normalized_warranty_text(product.warranty).presence || normalized_warranty_text(product.service&.warranty).presence
  end

  def warranty_value
    value = warranty_text
    return if value.blank?
    return value if value.match?(/\bans?\z/i)

    unit = value == "1" ? "an" : "ans"
    "#{value} #{unit}"
  end

  def normalized_warranty_text(value)
    text = value.to_s.squish
    return if text.blank?
    return if %w[0 false].include?(text.downcase)

    text
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

  def animated_service_card_definitions
    service = product.service

    [
      {
        key: :warranty,
        label: "Garantie #{warranty_value}",
        protected_label: "Garantie",
        impact_label: warranty_value,
        variant: :warranty,
        enabled: warranty_value.present?
      },
      {
        key: :anti_fire,
        label: "Protection Feu",
        protected_label: "Protection",
        impact_label: "Feu",
        variant: :fire,
        enabled: service&.anti_fire
      },
      {
        key: :rge,
        label: "Certifié RGE",
        protected_label: "Certifié",
        impact_label: "RGE",
        variant: :rge,
        enabled: service&.rge
      },
      {
        key: :wind_resistance,
        label: "Protection Vent",
        protected_label: "Protection",
        impact_label: "Vent",
        variant: :wind,
        enabled: service&.wind_resistance
      },
      {
        key: :anti_uv,
        label: "Protection UV",
        protected_label: "Protection",
        impact_label: "UV",
        variant: :uv,
        enabled: service&.anti_uv
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
