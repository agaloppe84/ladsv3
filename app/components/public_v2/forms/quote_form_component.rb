# frozen_string_literal: true

class PublicV2::Forms::QuoteFormComponent < ViewComponent::Base
  include PublicV2::Debuggable

  FIELD_LABELS = {
    lastname: "Nom",
    email: "Email",
    phone: "Telephone",
    city: "Ville",
    address: "Adresse",
    product: "Produit concerne",
    message: "Message"
  }.freeze

  FIELD_ERRORS = {
    lastname: "Indiquez votre nom.",
    email: "Indiquez un email valide.",
    phone: "Indiquez un telephone pour vous rappeler.",
    city: "Indiquez la ville du projet.",
    address: "Indiquez l'adresse du projet.",
    product: "Choisissez un produit ou l'option de conseil.",
    message: "Ajoutez quelques infos sur votre projet."
  }.freeze

  def initialize(quote:, url:, product_options: nil, products: [], debug: false)
    @quote = quote
    @product_options = product_options.presence || product_options_from_products(products)
    @url = url
    @debug = debug
  end

  private

  attr_reader :quote, :product_options, :url

  def field_classes(attribute, extra = nil)
    component_class_names(
      "pv2-quote-field",
      ("is-invalid" if field_error(attribute).present?),
      extra
    )
  end

  def field_error(attribute)
    return if quote.errors[attribute].blank?

    FIELD_ERRORS.fetch(attribute, quote.errors[attribute].to_sentence)
  end

  def field_label(attribute)
    FIELD_LABELS.fetch(attribute)
  end

  def field_data(attribute, kind: "text")
    {
      quote_form_target: "field",
      required: true,
      kind: kind,
      label: field_label(attribute),
      error_required: FIELD_ERRORS.fetch(attribute),
      error_email: "Indiquez un email au format correct.",
      error_phone: "Indiquez un telephone avec au moins 10 chiffres."
    }
  end

  def error_summary
    return unless quote.errors.any?

    "#{quote.errors.size} champ#{'s' if quote.errors.size > 1} a reprendre."
  end

  def product_options_from_products(products)
    product_options = Array(products).filter_map do |product|
      next if product.name.blank?

      {
        value: product.name.to_s,
        label: product.name.to_s,
        meta: product.category&.name.presence || "Catalogue",
        keywords: [product.name, product.category&.name, product.class.name].compact.join(" ")
      }
    end

    options = [
      {
        value: "A definir avec l'equipe",
        label: "Je ne sais pas encore",
        meta: "L'equipe vous orientera",
        keywords: "a definir equipe conseil produit"
      }
    ] + product_options.uniq { |option| option[:value] }

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

  def component_classes
    component_class_names("pv2-quote-form", "grid w-full min-w-0 gap-4", debug_class)
  end

  def component_data
    with_debug_data(
      controller: "quote-form",
      action: "input->quote-form#validate change->quote-form#validate focusout->quote-form#markTouched submit->quote-form#submit"
    )
  end
end
