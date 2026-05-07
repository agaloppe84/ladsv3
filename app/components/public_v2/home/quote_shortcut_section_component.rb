# frozen_string_literal: true

class PublicV2::Home::QuoteShortcutSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_options:, selected_product_id:, home_page:, debug: false)
    @product_options = product_options
    @selected_product_id = selected_product_id
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :product_options, :selected_product_id, :home_page

  def component_classes
    component_class_names(
      "pv2-home-section pv2-home-quote-panel",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 p-4 min-[821px]:p-5 min-[1121px]:grid-cols-[minmax(0,.72fr)_minmax(320px,.44fr)]",
      debug_class
    )
  end
end
