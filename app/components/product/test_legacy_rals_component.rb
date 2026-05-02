# frozen_string_literal: true

class Product::TestLegacyRalsComponent < ViewComponent::Base
  def initialize(rals:)
    @rals = rals
  end

  private

  attr_reader :rals

  def swatch_color(ral)
    ral.hex.presence || "#e2e8f0"
  end
end
