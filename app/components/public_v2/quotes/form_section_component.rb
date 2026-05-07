# frozen_string_literal: true

class PublicV2::Quotes::FormSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

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

  def component_classes
    [
      "pv2-quote-layout",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[minmax(0,1fr)_360px]",
      debug_class
    ].compact.join(" ")
  end
end
