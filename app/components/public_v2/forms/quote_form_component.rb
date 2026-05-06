# frozen_string_literal: true

class PublicV2::Forms::QuoteFormComponent < ViewComponent::Base
  def initialize(quote:, products:, url:)
    @quote = quote
    @products = products
    @url = url
  end

  private

  attr_reader :quote, :products, :url

  def product_options
    products.map { |product| [product.name, product.name] }
  end
end
