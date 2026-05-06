# frozen_string_literal: true

class PublicV2::Quotes::FormSectionComponent < ViewComponent::Base
  STEP_ITEMS = [
    "Vous envoyez le besoin et le produit repere si disponible.",
    "L'equipe vous rappelle pour valider dimensions et contraintes.",
    "Un devis clair est prepare avant prise de decision."
  ].freeze

  def initialize(quote_page:, url: nil)
    @quote_page = quote_page
    @url = url
  end

  private

  attr_reader :quote_page, :url

  def step_items
    STEP_ITEMS
  end

  def contact_items
    PublicV2::ContactInfo.quote_contact_items
  end

  def form_url
    url.presence || public_v2_quotes_path
  end
end
