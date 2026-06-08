# frozen_string_literal: true

class PublicV2::Products::CanvasSelectorComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product:, selector_url:, return_path:, quote_path:, debug: false)
    @product = product
    @selector_url = selector_url
    @return_path = return_path
    @quote_path = quote_path
    @debug = debug
  end

  private

  attr_reader :product, :selector_url, :return_path, :quote_path

  def component_classes
    component_class_names(
      "pv2-canvas-selector",
      "grid w-full min-w-0 gap-5",
      debug_class
    )
  end
end
