# frozen_string_literal: true

module PublicV2::ComponentSupport
  private

  def component_class_names(*tokens)
    tokens.flatten.compact_blank.join(" ")
  end

  def normalize_option(value, allowed_values, fallback)
    candidate = value.to_s.to_sym

    allowed_values.include?(candidate) ? candidate : fallback
  end
end
