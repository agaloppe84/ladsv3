# frozen_string_literal: true

class PublicV2::Home::QuoteShortcutSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_options:, selected_product_id:, debug: false)
    @product_options = product_options
    @selected_product_id = selected_product_id
    @debug = debug
  end

  private

  attr_reader :product_options, :selected_product_id

  def component_classes
    [
      "pv2-home-section pv2-home-quote-panel",
      "grid w-full min-w-0 grid-cols-1 items-start gap-6 p-5 min-[1121px]:grid-cols-[minmax(0,.78fr)_minmax(320px,.48fr)]",
      debug_class
    ].compact.join(" ")
  end
end
