# frozen_string_literal: true

class PublicV2::Forms::QuoteFormComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(quote:, products:, url:, debug: false)
    @quote = quote
    @products = products
    @url = url
    @debug = debug
  end

  private

  attr_reader :quote, :products, :url

  def product_options
    products.map { |product| [product.name, product.name] }
  end

  def component_classes
    ["pv2-quote-form", "grid w-full min-w-0 gap-4", debug_class].compact.join(" ")
  end

  def component_data
    with_debug_data(turbo: false)
  end
end
