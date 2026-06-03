# frozen_string_literal: true

class PublicV2::Forms::ProductSelectComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(name:, value:, options:, label: "Produit concerne", placeholder: "Choisir un produit", error: nil, required: true, debug: false)
    @name = name
    @value = value.to_s
    @options = options
    @label = label
    @placeholder = placeholder
    @error = error
    @required = required
    @debug = debug
  end

  private

  attr_reader :name, :value, :options, :label, :placeholder, :error, :required

  def input_id
    @input_id ||= "quote_product"
  end

  def label_id
    "#{input_id}_label"
  end

  def normalized_options
    options.map do |option|
      option = option.symbolize_keys
      {
        value: option[:value].to_s,
        label: option[:label].to_s,
        meta: option[:meta].to_s,
        keywords: [option[:label], option[:meta], option[:keywords]].compact.join(" ").downcase
      }
    end
  end

  def selected_option
    normalized_options.find { |option| option[:value] == value }
  end

  def selected_label
    selected_option&.dig(:label).presence || placeholder
  end

  def selected_meta
    selected_option&.dig(:meta).to_s
  end

  def component_classes
    component_class_names(
      "pv2-quote-field pv2-quote-product-select",
      ("is-invalid" if error.present?),
      debug_class
    )
  end

  def input_data
    {
      quote_product_select_target: "input",
      quote_form_target: "field",
      required: required,
      kind: "product",
      label: label,
      error_required: "Choisissez un produit ou l'option de conseil."
    }
  end
end
