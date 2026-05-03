# frozen_string_literal: true

class AdminV2::Ui::LoaderComponent < ViewComponent::Base
  VARIANTS = %i[dot_relay signal_bars grid_scan constellation].freeze

  def initialize(variant: :dot_relay, html_class: nil)
    @variant = variant.to_sym
    @html_class = html_class

    raise ArgumentError, "Unknown admin v2 loader variant: #{@variant}" unless VARIANTS.include?(@variant)
  end

  private

  attr_reader :variant, :html_class

  def classes
    ["admin-v2-loader", "admin-v2-loader--#{variant.to_s.dasherize}", html_class].compact.join(" ")
  end
end
