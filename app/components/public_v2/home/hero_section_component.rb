# frozen_string_literal: true

class PublicV2::Home::HeroSectionComponent < ViewComponent::Base
  def initialize(home_page:)
    @home_page = home_page
  end

  private

  attr_reader :home_page

  def featured_product_name
    home_page.featured_product&.name || "Store banne sur mesure"
  end

  def featured_category_name
    home_page.featured_product&.category&.name || "Protection solaire"
  end

  def featured_alt
    home_page.featured_product&.name || "Showroom Les Artisans du Store"
  end
end
