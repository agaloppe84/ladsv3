# frozen_string_literal: true

class PublicV2::Home::CategoryGridSectionComponent < ViewComponent::Base
  def initialize(category_cards:)
    @category_cards = category_cards
  end

  private

  attr_reader :category_cards
end
