# frozen_string_literal: true

class AdminV2::Ui::CustomSelectComponent < ViewComponent::Base
  def initialize(name:, options:, value: nil, label: nil, placeholder: "Choisir", input_id: nil, searchable: false, required: false, invalid_label: "Choisir une option")
    @name = name
    @options = options
    @value = value.to_s
    @label = label
    @placeholder = placeholder
    @input_id = input_id
    @searchable = searchable
    @required = required
    @invalid_label = invalid_label
  end

  private

  attr_reader :name, :options, :value, :label, :placeholder, :searchable, :required, :invalid_label

  def input_id
    @input_id.presence || "admin_v2_custom_select_#{name.parameterize(separator: "_")}"
  end

  def normalized_options
    options.map do |option|
      option = option.symbolize_keys
      {
        value: option[:value].to_s,
        label: option[:label].to_s,
        display_label: option[:display_label].presence || option[:label].to_s,
        meta: option[:meta].to_s,
        display_meta: option.key?(:display_meta) ? option[:display_meta].to_s : option[:meta].to_s,
        swatch: option[:swatch].to_s,
        keywords: [option[:label], option[:meta], option[:keywords]].compact.join(" ").downcase
      }
    end
  end

  def selected_option
    normalized_options.find { |option| option[:value] == value }
  end

  def selected_label
    selected_option&.dig(:display_label).presence || placeholder
  end

  def selected_meta
    selected_option&.dig(:display_meta).to_s
  end

  def selected_swatch
    selected_option&.dig(:swatch).to_s
  end
end
