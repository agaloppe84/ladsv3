# frozen_string_literal: true

module AdminV2::Categories::ColorPalette
  OPTIONS = [
    { value: "green", label: "Green", css: "rgba(127,169,150,1)" },
    { value: "green-blue", label: "Green blue", css: "rgba(133,184,139,1)" },
    { value: "blue", label: "Blue", css: "rgba(121,167,207,1)" },
    { value: "pink", label: "Pink", css: "rgba(209,163,164,1)" },
    { value: "red", label: "Red", css: "rgba(220,81,73,1)" },
    { value: "purple", label: "Purple", css: "rgba(181,113,143,1)" },
    { value: "yellow", label: "Yellow", css: "rgba(229,200,0,1)" },
    { value: "brown", label: "Brown", css: "rgba(160,82,45,1)" }
  ].freeze

  FALLBACK = { value: "", label: "Neutral", css: "#505766" }.freeze

  module_function

  def values
    OPTIONS.map { |option| option[:value] }
  end

  def options
    OPTIONS
  end

  def option_for(value)
    OPTIONS.find { |option| option[:value] == value.to_s } || FALLBACK
  end
end
