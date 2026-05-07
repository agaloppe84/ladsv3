# frozen_string_literal: true

class PublicV2::Home::CategoryGridSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category_cards:, debug: false)
    @category_cards = category_cards
    @debug = debug
  end

  private

  attr_reader :category_cards

  def component_classes
    [
      "pv2-home-section pv2-home-warm__catalog",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
