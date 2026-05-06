# frozen_string_literal: true

class PublicV2::Home::QuoteShortcutSectionComponent < ViewComponent::Base
  def initialize(product_options:, selected_product_id:)
    @product_options = product_options
    @selected_product_id = selected_product_id
  end

  private

  attr_reader :product_options, :selected_product_id
end
