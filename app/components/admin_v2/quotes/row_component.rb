# frozen_string_literal: true

class AdminV2::Quotes::RowComponent < ViewComponent::Base
  def initialize(quote:)
    @quote = quote
  end

  private

  attr_reader :quote

  def customer_name
    quote.lastname.presence || "Nom non renseigné"
  end

  def product_name
    quote.product.presence || "Produit non renseigné"
  end

  def city_name
    quote.city.presence || "Ville non renseignée"
  end

  def formatted_created_at
    helpers.l(quote.created_at, format: :short)
  end
end
