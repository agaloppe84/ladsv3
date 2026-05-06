# frozen_string_literal: true

class PublicV2::Forms::FieldComponent < ViewComponent::Base
  def initialize(label:, name:, type: :text, value: nil, placeholder: nil, options: [], rows: 4, hint: nil, error: nil, required: false, disabled: false, readonly: false, classes: nil)
    @label = label
    @name = name
    @type = type
    @value = value
    @placeholder = placeholder
    @options = options
    @rows = rows
    @hint = hint
    @error = error
    @required = required
    @disabled = disabled
    @readonly = readonly
    @classes = classes
  end

  private

  attr_reader :label, :name, :type, :value, :placeholder, :options, :rows, :hint, :error, :required, :disabled, :readonly, :classes

  def input_id
    @input_id ||= "public_v2_field_#{name.to_s.parameterize(separator: "_")}"
  end

  def component_classes
    [
      "pv2-ui-field",
      ("pv2-ui-field--invalid" if error.present?),
      "grid w-full min-w-0 gap-[0.35rem]",
      classes
    ].compact.join(" ")
  end

  def common_options
    {
      id: input_id,
      name: name,
      value: value,
      placeholder: placeholder,
      required: required,
      disabled: disabled,
      readonly: readonly
    }.compact
  end

  def normalized_options
    options.map do |option|
      option.is_a?(Array) ? option : [option, option]
    end
  end

  def selected_option?(option_value)
    option_value.to_s == value.to_s
  end
end
