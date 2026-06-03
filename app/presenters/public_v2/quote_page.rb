# frozen_string_literal: true

class PublicV2::QuotePage
  ContactItem = Struct.new(:label, :value, :path, keyword_init: true)

  def initialize(quote:, products:, selected_product:, selected_product_image:)
    @quote = quote
    @products = products
    @selected_product = selected_product
    @selected_product_image = selected_product_image
  end

  attr_reader :quote, :products, :selected_product, :selected_product_image

  def selected_product?
    selected_product.present?
  end

  def selected_product_category_name
    selected_product&.category&.name.presence || "Produit"
  end

  def selected_product_description
    product_attribute(:description).presence ||
      product_attribute(:infos).presence ||
      "Produit repere pour pre-remplir la demande et aider l'equipe a cadrer plus vite."
  end

  def hero_proof_items
    [
      { value: "48h", label: "Premier retour", text: "Un cadrage clair avant devis." },
      { value: product_count, label: "Produits", text: "Catalogue et destockage inclus." },
      { value: "200m2", label: "Showroom", text: "Comparer avant de choisir." }
    ]
  end

  def guide_steps
    [
      { kicker: "01", title: "Besoin", text: "Produit, usage, dimensions ou photo." },
      { kicker: "02", title: "Rappel", text: "L'equipe valide les contraintes utiles." },
      { kicker: "03", title: "Devis", text: "Retour clair pour decider." }
    ]
  end

  def form_focus_items
    [
      { value: "Produit", label: "Si vous savez deja", text: "Selectionnez une reference." },
      { value: "Projet", label: "Si c'est encore flou", text: "Expliquez le contexte." },
      { value: "Contact", label: "Pour vous rappeler", text: "Telephone et ville suffisent pour demarrer." }
    ]
  end

  def contact_items
    PublicV2::ContactInfo.quote_contact_items.map do |item|
      ContactItem.new(label: item[:label], value: item[:value], path: item[:path])
    end
  end

  def product_options
    base_options = products.filter_map do |product|
      next if product.name.blank?

      {
        value: product.name.to_s,
        label: product.name.to_s,
        meta: product_option_meta(product),
        keywords: [
          product.name,
          product_option_meta(product),
          product.class.name
        ].compact.join(" ")
      }
    end

    options = [
      {
        value: "A definir avec l'equipe",
        label: "Je ne sais pas encore",
        meta: "L'equipe vous orientera",
        keywords: "a definir equipe conseil produit"
      }
    ] + base_options.uniq { |option| option[:value] }

    if quote.product.present? && options.none? { |option| option[:value] == quote.product.to_s }
      options.unshift(
        value: quote.product.to_s,
        label: quote.product.to_s,
        meta: "Produit saisi",
        keywords: quote.product.to_s
      )
    end

    options
  end

  def product_count
    products.size
  end

  private

  def product_option_meta(product)
    product.category&.name.presence || "Catalogue"
  end

  def product_attribute(attribute_name)
    return unless selected_product.respond_to?(attribute_name)

    selected_product.public_send(attribute_name).to_s.squish
  end
end
