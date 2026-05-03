# frozen_string_literal: true

class AdminV2::Categories::ColorBadgeComponent < ViewComponent::Base
  def initialize(category:)
    @category = category
  end

  private

  attr_reader :category

  def option
    @option ||= AdminV2::Categories::ColorPalette.option_for(category.color)
  end

  def label
    option[:label].downcase
  end

  def swatch_style
    "background-color: #{option[:css]}"
  end

  def active?
    category.color.present?
  end
end
